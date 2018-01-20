//
//  HTTPURLConfiguration.m
//  ZhihuDaily
//
//  Created by 钟武 on 16/8/3.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "HTTPURLConfiguration.h"

@interface HTTPURLConfiguration ()

@property (nonatomic, copy) NSString *baiduDomain;

@end

@implementation HTTPURLConfiguration

SYNTHESIZE_SINGLETON_FOR_CLASS(HTTPURLConfiguration)

- (id)init{
    if (self = [super init]) {
        _baiduDomain = @"https://m.baidu.com/su?&from=wise_web&action=opensearch&ie=utf-8&wd=";
    }
    
    return self;
}

- (NSString *)baiduURLWithPath:(NSString *)path{
    if (!path) {
        return nil;
    }
    return [self.baiduDomain stringByAppendingString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
