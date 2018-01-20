//
//  NSURLCache+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/3/26.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "NSURLCache+ZWUtility.h"

@implementation NSURLCache (ZWUtility)

- (UIImage *)getCachedImageWithURL:(NSURL *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSCachedURLResponse *response = [self cachedResponseForRequest:request];
    NSData *data = response.data;
    if (data) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        return image;
    }
    return nil;
}

@end
