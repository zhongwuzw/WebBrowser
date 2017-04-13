//
//  NSDate+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/6.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "NSDate+ZWUtility.h"

static NSDateFormatter * SQLiteDateFormatter = nil;
static NSDateFormatter * SQLiteDateHourMinuteFormatter = nil;

@interface DateModel ()

@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, copy) NSString *hourMinute;

@end

@implementation DateModel

- (instancetype)initWithDate:(NSString *)date hourMinute:(NSString *)hourMinute{
    if (self = [super init]) {
        _dateString = date;
        _hourMinute = hourMinute;
    }
    return self;
}

@end

@implementation NSDate (ZWUtility)

+ (DateModel *)currentDateModel{
    NSDate *date = [NSDate date];
    
    DateModel *dateModel = [[DateModel alloc] initWithDate:[SQLiteDateFormatter stringFromDate:date] hourMinute:[SQLiteDateHourMinuteFormatter stringFromDate:date]];
    
    return dateModel;
}

+ (NSString *)currentDate{
    NSDate *date = [NSDate date];
    
    return [SQLiteDateFormatter stringFromDate:date];
}

+ (NSString *)yesterdayDate{
    NSDate *date = [NSDate date];
    
    return [SQLiteDateFormatter stringFromDate:[NSDate dateWithTimeInterval:-24 * 60 * 60 sinceDate:date]];
}

+ (void)initialize{
    if (self == [NSDate class]) {
        SQLiteDateFormatter = [[NSDateFormatter alloc] init];
        [SQLiteDateFormatter setDateFormat:@"yyyy-MM-dd"];
        SQLiteDateHourMinuteFormatter = [[NSDateFormatter alloc] init];
        [SQLiteDateHourMinuteFormatter setDateFormat:@"HH:mm"];
    }
}

@end
