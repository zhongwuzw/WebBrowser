//
//  HttpHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2016/11/10.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "HttpHelper.h"
#import "NSString+ZWUtility.h"

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
    if(content && [content length] > 0)
    {
        if([content hasPrefix:@"http://"])
        {
            NSString* temp = [content stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            NSRange position = [temp rangeOfString:@"/"];
            if(NSNotFound == position.location)
            {
                return [temp isValidURL];
            }
            else
            {
                temp = [temp substringToIndex:position.location];
                return [temp isValidURL];
            }
        }
        else if([content hasPrefix:@"https://"])
        {
            NSString* temp = [content stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            NSRange position = [temp rangeOfString:@"/"];
            if(NSNotFound == position.location)
            {
                return [temp isValidURL];
            }
            else
            {
                temp = [temp substringToIndex:position.location];
                return [temp isValidURL];
            }
        }
        else
        {
            NSURL* url = [NSURL URLWithString:[content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if(!url)
                return NO;
            
            NSRange position = [content rangeOfString:@"/"];
            if(NSNotFound == position.location)
            {
                if([content rangeOfString:@" "].location != NSNotFound)
                    return NO;
                
                return [content isValidURL];
            }
            else
            {
                NSString* temp = [content substringToIndex:position.location];
                if([temp rangeOfString:@" "].location != NSNotFound)
                    return NO;
                
                return [temp isValidURL];
            }
        }
    }

    return NO;
}

@end
