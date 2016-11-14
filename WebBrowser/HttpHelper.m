//
//  HttpHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2016/11/10.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "HttpHelper.h"

@implementation HttpHelper

+ (BOOL)canAppHandleURL:(NSURL *)url{
    if([url.absoluteString hasPrefix:@"itms-apps://itunes.apple.com/"])
        return YES;
    
    if ([url.absoluteString hasPrefix:@"http://itunes.apple.com/"]
        || [url.absoluteString hasPrefix:@"https://itunes.apple.com/"]
        ) {
#ifndef AUTOMATION
        NSString* matched = [self appstoreIdFromURL:url.absoluteString];
        if(matched && [matched length] > 0)
        {
            [Notifier postNotificationName:kModalAppstoreOpen object:matched];
        }
        else{
            [[UIApplication sharedApplication] openURL:url];
        }
#endif
        return YES;
    }
    if (![url.scheme isEqualToString:@"http"]
        && ![url.scheme isEqualToString:@"https"]
        && ![url.scheme isEqualToString:@"file"]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
#ifndef AUTOMATION
            [[UIApplication sharedApplication] openURL:url];
#endif
            return YES;
        }
    }
    return NO;
}

+ (NSString *)appstoreIdFromURL:(NSString *)url{
    NSError *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=id)([\\d]*)" options:NSRegularExpressionCaseInsensitive error:&error];//正则表达式：匹配前面是“id”的数字串
    if(error)
        return nil;
    NSTextCheckingResult *isMatch = [regex firstMatchInString:url options:0 range:NSMakeRange(0, [url length])];
    if(isMatch && [isMatch range].location != NSNotFound)
    {
        NSString* matched = [url substringWithRange:isMatch.range];
        if(matched && [matched length] > 0)
        {
            return matched;
        }
    }
    
    return nil;
}

+ (BOOL)isURL:(NSString *)content{
    return YES;
}

@end
