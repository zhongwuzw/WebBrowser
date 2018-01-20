//
//  HistoryDataManager.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/9.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistorySQLiteManager.h"

typedef void(^HistoryDataCompletion)(BOOL isNoMoreData);
typedef void(^HistoryDataLoadMoreCompletion)(NSArray<NSIndexPath *> *indexPaths, BOOL isNoMoreData);
typedef void(^HistoryDataDeleteCompletion)(BOOL success);

@interface HistorySectionModel : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) NSMutableArray<HistoryItemModel *> *itemsArray;

+ (HistorySectionModel *)historySectionWithDate:(NSString *)date itemsArray:(NSMutableArray<HistoryItemModel *> *)itemsArray;

@end

@interface HistoryDataManager : NSObject

- (instancetype)initWithCompletion:(HistoryDataCompletion)completion;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (HistoryItemModel *)historyModelForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)headerTitleForSection:(NSInteger)section;
- (void)getMoreDataWithCompletion:(HistoryDataLoadMoreCompletion)completion;
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath completion:(HistoryDataDeleteCompletion)completion;
- (void)deleleAllHistoryRecords;

@end
