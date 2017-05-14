//
//  BookmarkDataManager.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BookmarkSectionModel;

typedef void(^BookmarkDataCompletion)(BOOL success);
typedef void(^BookmarkDataInitCompletion)(NSArray<BookmarkSectionModel *> *array);
typedef void(^BookmarkDataDeleteCompletion)(BOOL success);

@interface BookmarkItemModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

+ (BookmarkItemModel *)bookmarkItemWithTitle:(NSString *)title url:(NSString *)url;

@end

@interface BookmarkSectionModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray<BookmarkItemModel *> *itemsArray;

+ (BookmarkSectionModel *)bookmarkSectionWithTitle:(NSString *)title itemsArray:(NSMutableArray<BookmarkItemModel *> *)items;

@end

@interface BookmarkDataManager : NSObject

- (instancetype)initWithCompletion:(BookmarkDataInitCompletion)completion;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (BookmarkItemModel *)bookmarkModelForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath completion:(BookmarkDataCompletion)completion;
- (void)moveSectionAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath completion:(BookmarkDataCompletion)completion;
- (NSString *)headerTitleForSection:(NSInteger)section;
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath completion:(BookmarkDataDeleteCompletion)completion;
- (void)deleleAllBookmarkRecords;
- (void)deleteSectionAtIndexPath:(NSIndexPath *)indexPath completion:(BookmarkDataDeleteCompletion)completion;
- (void)addBookmarkWithURL:(NSString *)url title:(NSString *)title sectionName:(NSString *)sectionName completion:(BookmarkDataCompletion)completion;
- (void)addBookmarkWithURL:(NSString *)url title:(NSString *)title sectionIndex:(NSInteger)sectionIndex completion:(BookmarkDataCompletion)completion;
- (void)addBookmarkWithURL:(NSString *)url title:(NSString *)title completion:(BookmarkDataCompletion)completion;
- (void)addBookmarkDirectoryWithName:(NSString *)name completion:(BookmarkDataCompletion)completion;
- (void)editBookmarkDirectoryWithName:(NSString *)name sectionIndex:(NSInteger)index completion:(BookmarkDataCompletion)completion;
- (void)editBookmarkItemWithModel:(BookmarkItemModel *)model oldIndexPath:(NSIndexPath *)oldIndexPath finalIndexPath:(NSIndexPath *)finalIndexPath completion:(BookmarkDataCompletion)completion;

@end
