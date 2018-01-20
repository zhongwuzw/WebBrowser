//
//  NSDate+ZWUtility.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/6.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateModel : NSObject

@property (nonatomic, copy, readonly) NSString *dateString;
@property (nonatomic, copy, readonly) NSString *hourMinute;

@end

@interface NSDate (ZWUtility)

+ (DateModel *)currentDateModel;
+ (NSString *)currentDate;
+ (NSString *)yesterdayDate;

@end
