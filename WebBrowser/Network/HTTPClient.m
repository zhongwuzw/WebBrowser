//
//  HTTPClient.m
//  ZhihuDaily
//
//  Created by 钟武 on 16/8/3.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "HTTPClient.h"
#import "HTTPURLConfiguration.h"
#import "HTTPManager.h"
#import "BaseResponseModel.h"

@interface HTTPClient ()

@property (nonatomic, strong) HTTPManager *httpManager;

@end

@implementation HTTPClient

SYNTHESIZE_SINGLETON_FOR_CLASS(HTTPClient)

- (id)init{
    if (self = [super init]) {
        _httpManager = [HTTPManager new];
    }
    
    return self;
}

- (void)getImageWithURL:(NSURL *)url completion:(HttpClientImageSuccessBlock)completion{
    [_httpManager getImageWithURL:url completion:completion];
}

//- (NSURLSessionDataTask *)getPreviousNewsWithDate:(NSString *)date success:(HttpClientSuccessBlock)success
//                                             fail:(HttpClientFailureBlock)fail{
//    NSString *relativePath = [[HTTPURLConfiguration sharedInstance] previousNews];
//    if (date) {
//        relativePath = [relativePath stringByAppendingString:date];
//    }
//    
//    return [_httpManager GET:relativePath parameters:nil modelClass:[BaseResponseModel class] success:success failure:fail];
//}

@end
