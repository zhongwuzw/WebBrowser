//
//  NSData+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/9/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "NSData+ZWUtility.h"

@implementation NSData (ZWUtility)

- (NSString *)jsonString{
    return [[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
