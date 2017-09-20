//
//  HistoryDataManager.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/9.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistoryDataManager.h"

static NSString *const kTodayDate = @"今天";
static NSString *const kYesterdayDate = @"昨天";
static NSString *const kBeforeDate = @"以前";
static NSInteger const kLimit = 50;

typedef void(^HistoryDataTempCompletion)(void);

@implementation HistorySectionModel

+ (HistorySectionModel *)historySectionWithDate:(NSString *)date itemsArray:(NSMutableArray<HistoryItemModel *> *)itemsArray{
    HistorySectionModel *section = [HistorySectionModel new];
    section.date = date;
    section.itemsArray = itemsArray;
    
    return section;
}

@end

@interface HistoryDataManager ()

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSMutableArray<HistorySectionModel *> *historyArray;
@property (nonatomic, strong) HistorySQLiteManager *historySQLiteManager;
@property (nonatomic, copy) HistoryDataCompletion completion;
@property (nonatomic, assign) BOOL isNoMoreData;

@end

@implementation HistoryDataManager

- (instancetype)initWithCompletion:(HistoryDataCompletion)completion{
    if (self = [super init]) {
        _isNoMoreData = NO;
        _offset = 0;
        _historyArray = [NSMutableArray arrayWithCapacity:3];
        _completion = completion;
        _historySQLiteManager = [HistorySQLiteManager sharedInstance];
        [self initData];
    }
    return self;
}

- (void)initData{
    WEAK_REF(self)
    HistoryDataTempCompletion completion = ^{
        [self_.historySQLiteManager getHistoryDataByLimit:kLimit offset:self.offset handler:^(NSMutableArray<HistoryItemModel *> *array){
            // always called in main thread
            STRONG_REF(self_)
            if (self__) {
                [self__ updateNoMoreDataWithCount:array.count];
                [self__ addSectionDataWithArray:array date:kBeforeDate];
                if (self__.completion) {
                    self__.completion(self__.isNoMoreData);
                }
            }
        }];
    };
    
    [self.historySQLiteManager getTodayAndYesterdayHistoryDataWithHandler:^(NSMutableArray<HistoryItemModel *> *today, NSMutableArray<HistoryItemModel *> *yesterday){
        // always called in main thread
        STRONG_REF(self_)
        if (self__) {
            [self__ addSectionDataWithArray:today date:kTodayDate];
            [self__ addSectionDataWithArray:yesterday date:kYesterdayDate];
            completion();
        }
    }];
}

- (void)getMoreDataWithCompletion:(HistoryDataLoadMoreCompletion)completion{
    WEAK_REF(self)
    [self.historySQLiteManager getHistoryDataByLimit:kLimit offset:self.offset handler:^(NSArray<HistoryItemModel *> *array){
        STRONG_REF(self_)
        if (self__) {
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:array.count];
            
            if (array.count > 0) {
                NSInteger section = self__.historyArray.count - 1;
                NSInteger startIdx = self__.historyArray[section].itemsArray.count;
                
                for (int i = 0; i < array.count; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:startIdx inSection:section];
                    [indexPaths addObject:indexPath];
                    startIdx++;
                }
            }
            
            [self__ addBeforeHistoryDataWithArray:array];
            [self__ updateNoMoreDataWithCount:array.count];
            
            if (completion) {
                completion(indexPaths, self__.isNoMoreData);
            }
        }
    }];
}

- (void)updateNoMoreDataWithCount:(NSInteger)count{
    self.isNoMoreData = (count < kLimit);
}

- (void)addBeforeHistoryDataWithArray:(NSArray<HistoryItemModel *> *)array{
    if (!array || array.count == 0) {
        return;
    }
    
    HistorySectionModel *model = [self.historyArray lastObject];
    
    if (model) {
        [model.itemsArray addObjectsFromArray:array];
        _offset += array.count;
    }
}

- (void)addSectionDataWithArray:(NSMutableArray<HistoryItemModel *> *)array date:(NSString *)date{
    if (!array || array.count == 0) {
        return;
    }
    
    HistorySectionModel *model = [HistorySectionModel historySectionWithDate:date itemsArray:array];
    _offset += array.count;
    [self.historyArray addObject:model];
}

- (NSInteger)numberOfSections{
    return self.historyArray.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{
    if (section < self.historyArray.count) {
        return self.historyArray[section].itemsArray.count;
    }
    return 0;
}

- (NSString *)headerTitleForSection:(NSInteger)section{
    NSString *title;
    if (section < self.historyArray.count) {
        title = self.historyArray[section].date;
    }
    return title;
}

- (HistoryItemModel *)historyModelForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section < self.historyArray.count && row < self.historyArray[section].itemsArray.count) {
        return self.historyArray[section].itemsArray[row];
    }
    return nil;
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath completion:(HistoryDataDeleteCompletion)completion{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    BOOL success = NO;
    
    if (section < self.historyArray.count && row < self.historyArray[section].itemsArray.count) {
        HistoryItemModel *model = self.historyArray[section].itemsArray[row];
        
        [self.historyArray[section].itemsArray removeObjectAtIndex:row];
        success = YES;
        
        WEAK_REF(self)
        [self.historySQLiteManager deleteHistoryRecordWithModel:model completion:^(BOOL success){
            STRONG_REF(self_)
            if (self__ && success) {
                self__.offset--;
            }
        }];
    }
    
    if (completion) {
        completion(success);
    }
}

- (void)deleleAllHistoryRecords{
    [self.historyArray removeAllObjects];
    self.offset = 0;
    [self.historySQLiteManager deleteAllHistoryRecords];
}

@end
