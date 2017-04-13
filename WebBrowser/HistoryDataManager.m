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

@implementation HistorySectionModel

+ (HistorySectionModel *)historySectionWithDate:(NSString *)date itemsArray:(NSArray<HistoryItemModel *> *)itemsArray{
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

@end

@implementation HistoryDataManager

- (instancetype)initWithCompletion:(HistoryDataCompletion)completion{
    if (self = [super init]) {
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
    [self.historySQLiteManager getTodayAndYesterdayHistoryDataWithHandler:^(NSArray<HistoryItemModel *> *today, NSArray<HistoryItemModel *> *yesterday){
        STRONG_REF(self_)
        if (self__) {
            [self__ addSectionDataWithArray:today date:kTodayDate];
            [self__ addSectionDataWithArray:yesterday date:kYesterdayDate];
            if (self__.completion) {
                dispatch_main_safe_async(^{
                    self__.completion();
                })
            }
        }
    }];
}

- (void)addSectionDataWithArray:(NSArray<HistoryItemModel *> *)array date:(NSString *)date{
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

@end
