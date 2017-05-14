//
//  BookmarkDataManager.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkDataManager.h"

#ifdef DEBUG
#define QueueCheck(shouldSyncQueue) do {                                                       \
    BookmarkDataManager *manager = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);                                            \
    assert((shouldSyncQueue ? manager == self : manager != self) && "operate on sectionArray needs in sync queue");   \
} while (0)
#else
#define QueueCheck(shouldSyncQueue)
#endif

static NSString *const kBookmarkPlistFileName = @"bookmark.plist";
static NSString *const kBookmarkArchiveDataKey = @"kBookmarkArchiveDataKey";
static NSString *const kBookmarkDefaultSectionName = @"默认文件夹";
static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

@interface BookmarkDataManager ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSMutableArray<BookmarkSectionModel *> *sectionArray;

@end

@implementation BookmarkDataManager

- (instancetype)init{
    return [self initWithCompletion:nil];
}

- (instancetype)initWithCompletion:(BookmarkDataInitCompletion)completion{
    if (self = [super init]) {
        NSString *queueName = [NSString stringWithFormat:@"com.zhongwu.Bookmark-%@", [[NSUUID UUID] UUIDString]];
        _syncQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_syncQueue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
        _filePath = [DocumentPath stringByAppendingPathComponent:kBookmarkPlistFileName];
        
        [self loadBookmarkModelArrayWithCompletion:completion];
    }
    return self;
}

- (void)loadBookmarkModelArrayWithCompletion:(BookmarkDataInitCompletion)completion{
    dispatch_async(_syncQueue, ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            NSData *data = [NSData dataWithContentsOfFile:_filePath options:NSDataReadingUncached error:nil];
            if (data) {
                NSKeyedUnarchiver *unarchiver;
                @try {
                    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                    NSArray<BookmarkSectionModel *> *array = [unarchiver decodeObjectForKey:kBookmarkArchiveDataKey];
                    
                    if (array && [array isKindOfClass:[NSMutableArray<BookmarkSectionModel *> class]] && array.count > 0) {
                        _sectionArray = (NSMutableArray<BookmarkSectionModel *> *)array;
                    }
                    else
                    {
                        _sectionArray = [self defaultArray];
                    }
                } @catch (NSException *exception) {
                    DDLogError(@"bookmark unarchive error");
                    _sectionArray = [self defaultArray];
                } @finally {
                    [unarchiver finishDecoding];
                }
            }
            else{
                _sectionArray = [self defaultArray];
            }
        }
        else{
            _sectionArray = [self defaultArray];
        }
        if (completion) {
            dispatch_main_safe_async(^{
                completion([_sectionArray copy]);
            })
        }
    });
}

- (NSMutableArray<BookmarkSectionModel *> *)defaultArray{
    NSMutableArray<BookmarkSectionModel *> *array = [NSMutableArray array];

    BookmarkSectionModel *sectionModel = [BookmarkSectionModel bookmarkSectionWithTitle:kBookmarkDefaultSectionName itemsArray:nil];
    [array addObject:sectionModel];
    
    return array;
}

- (void)saveBookmarkSectionModelToDisk{
    QueueCheck(YES);
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_sectionArray forKey:kBookmarkArchiveDataKey];
    [archiver finishEncoding];
    
    [data writeToFile:_filePath atomically:YES];
}

- (NSInteger)numberOfSections{
    QueueCheck(NO);
    __block NSInteger count = 0;
    dispatch_sync(_syncQueue,^{
        count = self.sectionArray.count;
    });
    return count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{
    QueueCheck(NO);
    __block NSInteger count = 0;
    dispatch_sync(_syncQueue, ^{
        if (section < self.sectionArray.count) {
            count = self.sectionArray[section].itemsArray.count;
        }
    });
    return count;
}

- (BookmarkItemModel *)bookmarkModelForRowAtIndexPath:(NSIndexPath *)indexPath{
    QueueCheck(NO);
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    __block BookmarkItemModel *itemModel = nil;
    
    dispatch_sync(_syncQueue, ^{
        if (section < self.sectionArray.count && row < self.sectionArray[section].itemsArray.count) {
            itemModel = self.sectionArray[section].itemsArray[row];
        }
    });
    return itemModel;
}

- (NSString *)headerTitleForSection:(NSInteger)section{
    QueueCheck(NO);
    __block NSString *title;
    dispatch_sync(_syncQueue, ^{
        if (section < self.sectionArray.count) {
            title = self.sectionArray[section].title;
        }
    });
    return title;
}

#pragma mark - Move

- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath completion:(BookmarkDataCompletion)completion{
    QueueCheck(NO);
    
    BookmarkItemModel *itemModel = [self bookmarkModelForRowAtIndexPath:fromIndexPath];
    NSInteger toSection = newIndexPath.section;
    NSInteger toRow = newIndexPath.row;
    
    dispatch_async(_syncQueue, ^{
        if (fromIndexPath == newIndexPath && !itemModel && toSection >= self.sectionArray.count && toRow > self.sectionArray[toSection].itemsArray.count) {
            if (completion) {
                dispatch_main_safe_async(^{
                    completion(NO);
                })
            }
            return;
        }
        
        NSInteger fromSection = fromIndexPath.section;
        
        [self.sectionArray[fromSection].itemsArray removeObject:itemModel];
        self.sectionArray[toSection].itemsArray = self.sectionArray[toSection].itemsArray ? self.sectionArray[toSection].itemsArray : [NSMutableArray array];
        [self.sectionArray[toSection].itemsArray insertObject:itemModel atIndex:toRow];
        dispatch_async(_syncQueue, ^{
            [self saveBookmarkSectionModelToDisk];
        });
        
        if (completion) {
            dispatch_main_safe_async(^{
                completion(YES);
            })
        }
    });
}

- (void)moveSectionAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath completion:(BookmarkDataCompletion)completion{
    QueueCheck(NO);
    
    NSInteger fromSection = fromIndexPath.section;
    NSInteger toSection = newIndexPath.section;
    
    dispatch_async(_syncQueue, ^{
        if (!(fromSection < self.sectionArray.count && toSection < self.sectionArray.count) && completion) {
            dispatch_main_safe_async(^{
                completion(NO);
            })
            return ;
        }
        BookmarkSectionModel *sectionModel = self.sectionArray[fromSection];
        [self.sectionArray removeObjectAtIndex:fromSection];
        [self.sectionArray insertObject:sectionModel atIndex:toSection];
        
        dispatch_async(_syncQueue, ^{
            [self saveBookmarkSectionModelToDisk];
        });
        
        if (completion) {
            dispatch_main_safe_async(^{
                completion(YES);
            })
        }
    });
}

#pragma mark - Delete

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath completion:(BookmarkDataDeleteCompletion)completion{
    QueueCheck(NO);
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    dispatch_async(_syncQueue, ^{
        if (section < self.sectionArray.count && row < self.sectionArray[section].itemsArray.count) {
            [self.sectionArray[section].itemsArray removeObjectAtIndex:row];
            dispatch_async(_syncQueue, ^{
                [self saveBookmarkSectionModelToDisk];
            });
            
            if (completion) {
                dispatch_main_safe_async(^{
                    completion(YES);
                })
            }
        }
        else if(completion){
            dispatch_main_safe_async(^{
                completion(NO);
            })
        }
    });
}

- (void)deleleAllBookmarkRecords{
    QueueCheck(NO);
    dispatch_sync(_syncQueue, ^{
        [self.sectionArray removeAllObjects];
        dispatch_async(_syncQueue, ^{
            [self saveBookmarkSectionModelToDisk];
        });
    });
}

- (void)deleteSectionAtIndexPath:(NSIndexPath *)indexPath completion:(BookmarkDataDeleteCompletion)completion{
    QueueCheck(NO);
    dispatch_async(_syncQueue, ^{
        NSInteger section = indexPath.section;
        BOOL isSuccess = NO;
        if (section < self.sectionArray.count) {
            [self.sectionArray removeObjectAtIndex:section];
            isSuccess = YES;
            dispatch_async(_syncQueue, ^{
                [self saveBookmarkSectionModelToDisk];
            });
        }
        if (completion) {
            dispatch_main_safe_async(^{
                completion(isSuccess);
            })
        }
    });
}

#pragma mark - Add

- (void)addBookmarkWithURL:(NSString *)url title:(NSString *)title completion:(BookmarkDataCompletion)completion{
    [self addBookmarkWithURL:url title:title sectionName:nil completion:completion];
}

- (void)addBookmarkWithURL:(NSString *)url title:(NSString *)title sectionName:(NSString *)sectionName completion:(BookmarkDataCompletion)completion{
    QueueCheck(NO);
    if (url.length == 0 || title.length == 0) {
        if (completion) {
            dispatch_main_safe_async(^{
                completion(NO);
            })
        }
        return;
    }
    
    sectionName = sectionName.length ? sectionName : kBookmarkDefaultSectionName;
    
    dispatch_async(_syncQueue, ^{
        __block NSUInteger index = NSNotFound;
        [self.sectionArray enumerateObjectsUsingBlock:^(BookmarkSectionModel *model, NSUInteger idx, BOOL *stop){
            if ([model.title isEqualToString:sectionName]) {
                index = idx;
            }
        }];
        if (index == NSNotFound) {
            [self.sectionArray insertObject:[BookmarkSectionModel bookmarkSectionWithTitle:kBookmarkDefaultSectionName itemsArray:nil] atIndex:0];
            index = 0;
        }
        
        BookmarkItemModel *itemModel = [BookmarkItemModel bookmarkItemWithTitle:title url:url];
        self.sectionArray[index].itemsArray = (self.sectionArray[index].itemsArray) ? self.sectionArray[index].itemsArray : [NSMutableArray array];
        [self.sectionArray[index].itemsArray addObject:itemModel];
        
        dispatch_async(_syncQueue, ^{
            [self saveBookmarkSectionModelToDisk];
        });
        
        if (completion) {
            dispatch_main_safe_async(^{
                completion(YES);
            })
        }
    });
}

- (void)addBookmarkWithURL:(NSString *)url title:(NSString *)title sectionIndex:(NSInteger)sectionIndex completion:(BookmarkDataCompletion)completion{
    QueueCheck(NO);
    
    if (url.length == 0 || title.length == 0) {
        if (completion) {
            dispatch_main_safe_async(^{
                completion(NO);
            })
        }
        return;
    }
    
    dispatch_async(_syncQueue, ^{
        BOOL success = NO;
        if (sectionIndex < self.sectionArray.count) {
            success = YES;
            BookmarkItemModel *itemModel = [BookmarkItemModel bookmarkItemWithTitle:title url:url];
            self.sectionArray[sectionIndex].itemsArray = (self.sectionArray[sectionIndex].itemsArray) ? self.sectionArray[sectionIndex].itemsArray : [NSMutableArray array];
            [self.sectionArray[sectionIndex].itemsArray addObject:itemModel];
            
            dispatch_async(_syncQueue, ^{
                [self saveBookmarkSectionModelToDisk];
            });
        }
        
        if (completion) {
            dispatch_main_safe_async(^{
                completion(YES);
            })
        }
    });
}

- (void)addBookmarkDirectoryWithName:(NSString *)name completion:(BookmarkDataCompletion)completion{
    QueueCheck(NO);
    
    dispatch_async(_syncQueue, ^{
        __block BOOL isExisted = NO;
        [self.sectionArray enumerateObjectsUsingBlock:^(BookmarkSectionModel *model, NSUInteger idx, BOOL *stop){
            if ([model.title isEqualToString:name]) {
                isExisted = YES;
                *stop = YES;
            }
        }];
        
        if (!isExisted) {
            BookmarkSectionModel *model = [BookmarkSectionModel bookmarkSectionWithTitle:name itemsArray:nil];
            [self.sectionArray addObject:model];
            dispatch_async(_syncQueue, ^{
                [self saveBookmarkSectionModelToDisk];
            });
        }
        
        if (completion) {
            dispatch_main_safe_async(^{
                completion(!isExisted);
            })
        }
    });
}

#pragma mark - Edit

- (void)editBookmarkDirectoryWithName:(NSString *)name sectionIndex:(NSInteger)index completion:(BookmarkDataCompletion)completion{
    QueueCheck(NO);
    
    dispatch_async(_syncQueue, ^{
        __block BOOL isSuccess = YES;
        if (index < self.sectionArray.count) {
            [self.sectionArray enumerateObjectsUsingBlock:^(BookmarkSectionModel *model, NSUInteger idx, BOOL *stop){
                if ([model.title isEqualToString:name] && idx != index) {
                    isSuccess = NO;
                    *stop = YES;
                }
            }];
        }
        else{
            isSuccess = NO;
        }
        
        if (isSuccess) {
            self.sectionArray[index].title = name;
            dispatch_async(_syncQueue, ^{
                [self saveBookmarkSectionModelToDisk];
            });
        }
        
        if (completion) {
            dispatch_main_safe_async(^{
                completion(isSuccess);
            })
        }
    });
}

- (void)editBookmarkItemWithModel:(BookmarkItemModel *)model oldIndexPath:(NSIndexPath *)oldIndexPath finalIndexPath:(NSIndexPath *)finalIndexPath completion:(BookmarkDataCompletion)completion{
    QueueCheck(NO);
    
    dispatch_async(_syncQueue, ^{
        BOOL success = YES;
        NSInteger oldSection = oldIndexPath.section;
        NSInteger oldRow = oldIndexPath.row;
        NSInteger finalSection = finalIndexPath.section;
        
        if ([oldIndexPath isEqual:finalIndexPath]) {
            if (oldSection < self.sectionArray.count && oldRow < self.sectionArray[oldSection].itemsArray.count) {
                [self.sectionArray[oldSection].itemsArray replaceObjectAtIndex:oldRow withObject:model];
            }
        }
        else if (oldSection < self.sectionArray.count && oldRow < self.sectionArray[oldSection].itemsArray.count) {
            [self.sectionArray[oldSection].itemsArray removeObjectAtIndex:oldRow];
            [self.sectionArray[finalSection].itemsArray addObject:model];
        }
        else{
            success = NO;
        }
        
        if (success) {
            dispatch_async(_syncQueue, ^{
                [self saveBookmarkSectionModelToDisk];
            });
        }
        
        if (completion) {
            dispatch_main_safe_async(^{
                completion(success);
            })
        }
    });
}

@end

static NSString *const kBookmarkItemTitleKey = @"kBookmarkItemTitleKey";
static NSString *const kBookmarkItemUrlKey = @"kBookmarkItemUrlKey";

@interface BookmarkItemModel () <NSSecureCoding>

@end

@implementation BookmarkItemModel

+ (BookmarkItemModel *)bookmarkItemWithTitle:(NSString *)title url:(NSString *)url{
    BookmarkItemModel *item = [BookmarkItemModel new];
    item.title = title;
    item.url = url;
    
    return item;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectOfClass:[NSString class] forKey:kBookmarkItemTitleKey];
        _url = [aDecoder decodeObjectOfClass:[NSString class] forKey:kBookmarkItemUrlKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:kBookmarkItemTitleKey];
    [aCoder encodeObject:self.url forKey:kBookmarkItemUrlKey];}

+ (BOOL)supportsSecureCoding{
    return YES;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    BookmarkItemModel *itemModel = [[self class] allocWithZone:zone];
    
    itemModel.title = [self.title copyWithZone:zone];
    itemModel.url = [self.url copyWithZone:zone];
    
    return itemModel;
}

@end

static NSString *const kBookmarkSectionTitleKey = @"kBookmarkSectionTitleKey";
static NSString *const kBookmarkSectionArrayKey = @"kBookmarkSectionArrayKey";

@interface BookmarkSectionModel () <NSSecureCoding>

@end

@implementation BookmarkSectionModel

+ (BookmarkSectionModel *)bookmarkSectionWithTitle:(NSString *)title itemsArray:(NSMutableArray<BookmarkItemModel *> *)items{
    BookmarkSectionModel *sectionModel = [BookmarkSectionModel new];
    sectionModel.title = title;
    sectionModel.itemsArray = items;
    
    return sectionModel;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectOfClass:[NSString class] forKey:kBookmarkSectionTitleKey];
        _itemsArray = [[aDecoder decodeObjectOfClass:[NSString class] forKey:kBookmarkSectionArrayKey] mutableCopy];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:kBookmarkSectionTitleKey];
    [aCoder encodeObject:self.itemsArray forKey:kBookmarkSectionArrayKey];
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

@end
