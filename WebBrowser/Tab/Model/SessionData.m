//
//  SessionData.m
//  WebBrowser
//
//  Created by 钟武 on 2017/3/15.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SessionData.h"

static NSString *const kCurrentPageKey = @"CurrentPageKey";
static NSString *const kURLsKey = @"URLsKey";

@interface SessionData () <NSCoding>

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, copy) NSArray<NSString *> *urls;

@end

@implementation SessionData

- (NSDictionary *)jsonDictionary{
    NSAssert(_urls, @"urls should has value");
    return @{
        @"currentPage" :  @(_currentPage),
        @"history"        : _urls
        };
}

- (instancetype)initWithCurrentPage:(NSInteger)currentPage urls:(NSArray <NSString *> *)urls{
    if (self = [self init]) {
        _currentPage = currentPage;
        _urls = urls;
    }
    return self;
}

#pragma mark - NSCoding Protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _currentPage = [aDecoder decodeIntegerForKey:kCurrentPageKey];
        _urls = [aDecoder decodeObjectForKey:kURLsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.currentPage forKey:kCurrentPageKey];
    [aCoder encodeObject:self.urls forKey:kURLsKey];
}

@end
