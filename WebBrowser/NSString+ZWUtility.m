//
//  NSString+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

static NSString * const kURLRegEx = @"((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";

#import "NSString+ZWUtility.h"

@implementation NSString (ZWUtility)

- (BOOL)isValidURL{
    NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",kURLRegEx];
    return [urlPredic evaluateWithObject:self];
}

@end
