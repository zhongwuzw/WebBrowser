//
//  NSURL+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/2/18.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "NSURL+ZWUtility.h"

@implementation NSURL (ZWUtility)

- (BOOL)isErrorPageURL{
    return [self.scheme isEqualToString:@"http"] && [self.host isEqualToString:@"localhost"] && [self.path isEqualToString:@"/errors/error.html"];
}

- (NSURL *)originalURLFromErrorURL{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    
    __block NSString *queryURL = nil;
    
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop){
        if ([item.name isEqualToString:@"url"]) {
            queryURL = item.value;
            *stop = YES;
        }
    }];
    
    return [NSURL URLWithString:queryURL];
}

- (BOOL)isLocal{
    return [self.host.lowercaseString isEqualToString:@"localhost"] || [self.host isEqualToString:@"127.0.0.1"];
}

@end
