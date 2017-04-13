//
//  HistorySQLiteManager.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/6.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ZWSQLiteManager.h"

@interface HistoryItemModel : NSObject

@property (nonatomic, copy) NSString *hourMinute;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *time;

+ (HistoryItemModel *)historyItemWithHourMinute:(NSString *)hourMinute url:(NSString *)url title:(NSString *)title time:(NSString *)time;

@end

typedef void(^HistoryCompletionHandler)(NSArray *);
typedef void(^HistoryTodayYesterdayCompletionHandler)(NSArray<HistoryItemModel *> *today,NSArray<HistoryItemModel *> *yesterday);

@interface HistorySQLiteManager : ZWSQLiteManager

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HistorySQLiteManager)
- (void)insertOrUpdateHistoryWithURL:(NSString *)url title:(NSString *)title;
- (void)getHistoryDataByLimit:(NSInteger)limit offset:(NSInteger)offset handler:(HistoryCompletionHandler)handler;
- (void)getTodayAndYesterdayHistoryDataWithHandler:(HistoryTodayYesterdayCompletionHandler)handler;

@end
