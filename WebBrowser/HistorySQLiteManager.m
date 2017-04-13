//
//  HistorySQLiteManager.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/6.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistorySQLiteManager.h"
#import "NSDate+ZWUtility.h"
#import "ZWSQLSQL.h"

static NSString *const kHistorySQLiteName = @"history.db";

@implementation HistoryItemModel

+ (HistoryItemModel *)historyItemWithHourMinute:(NSString *)hourMinute url:(NSString *)url title:(NSString *)title time:(NSString *)time{
    HistoryItemModel *item = [HistoryItemModel new];
    item.hourMinute = hourMinute;
    item.url = url;
    item.title = title;
    item.title = title;
    
    return item;
}

@end

@implementation HistorySQLiteManager

SYNTHESIZE_SINGLETON_FOR_CLASS(HistorySQLiteManager)

- (instancetype)init{
    if (self = [super initWithPath:[DocumentPath stringByAppendingPathComponent:kHistorySQLiteName]]) {
    }
    return self;
}

- (void)databaseManagerDidCreated{
    ZW_IN_DATABASE(db, ({
        [db executeZWUpdate:ZW_SQL_CREATE_HISTORY_TABLE];
        [db executeZWUpdate:ZW_SQL_CREATE_HISTORY_INDEX_TABLE];
    }));
}

- (void)insertOrUpdateHistoryWithURL:(NSString *)url title:(NSString *)title{
    if (!url || url.length == 0) {
        return ;
    }
    DateModel *dateModel = [NSDate currentDateModel];
    
    ZW_IN_DATABASE(db, ({
        [db executeZWUpdate:ZW_SQL_INSERT_OR_IGNORE_HISTORY withArgumentsInArray:[self getHistoryInsertArrayWithURL:url title:title dateModel:dateModel]];
    }));
}

- (NSArray *)getHistoryInsertArrayWithURL:(NSString *)url title:(NSString *)title dateModel:(DateModel *)dateModel{
    title = (!title || title.length == 0) ? @"..." : title;
    return @[
             url,
             title,
             dateModel.hourMinute,
             dateModel.dateString
             ];
}

- (void)getHistoryDataByLimit:(NSInteger)limit offset:(NSInteger)offset handler:(HistoryCompletionHandler)handler{
    if (!handler) {
        return;
    }
    ZW_IN_DATABASE(db, ({
        FMResultSet *resultSet = [db executeZWQuery:ZW_SQL_SELECT_HISTORY withArgumentsInArray:@[@(limit), @(offset)]];
        NSArray *array = [self getHistoryResultWithDBResultSet:resultSet];
        
        dispatch_main_safe_async(^{
            handler(array);
        })
    }));
}

- (void)getTodayAndYesterdayHistoryDataWithHandler:(HistoryTodayYesterdayCompletionHandler)handler{
    if (!handler) {
        return;
    }
    
    ZW_IN_DATABASE(db, ({
        FMResultSet *resultSet = [db executeZWQuery:ZW_SQL_SELECT_TODAY_YESTERDAY_HISTORY withArgumentsInArray:@[[NSDate currentDate]]];
        NSArray *todayArray = [self getHistoryResultWithDBResultSet:resultSet];
        
        resultSet = [db executeZWQuery:ZW_SQL_SELECT_TODAY_YESTERDAY_HISTORY withArgumentsInArray:@[[NSDate yesterdayDate]]];
        NSArray *yesterdayArray = [self getHistoryResultWithDBResultSet:resultSet];
        
        dispatch_main_safe_async(^{
            handler(todayArray, yesterdayArray);
        })
    }));
}

- (NSArray<HistoryItemModel *> *)getHistoryResultWithDBResultSet:(FMResultSet *)resultSet{
    NSMutableArray *array = [NSMutableArray array];
    
    while ([resultSet next]) {
        @autoreleasepool {
            NSString *url = [resultSet stringForColumn:ZW_FIELD_URL];
            NSString *title = [resultSet stringForColumn:ZW_FIELD_TITLE];
            NSString *hourMinute = [resultSet stringForColumn:ZW_FIELD_HOUR_MINUTE];
            NSString *date = [resultSet stringForColumn:ZW_FIELD_TIME];
            
            HistoryItemModel *model = [HistoryItemModel historyItemWithHourMinute:hourMinute url:url title:title time:date];
            [array addObject:model];
        }
    }
    
    return array;
}

@end
