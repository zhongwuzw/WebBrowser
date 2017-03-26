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
    if (([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) && [url.host isEqualToString:@"itunes.apple.com"]) {
        return YES;
    }
    return NO;
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
