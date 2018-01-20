//
//  URLConnectionDelegateProxy.h
//  WebBrowser
//
//  Created by 钟武 on 2017/10/31.
//  Copyright © 2017年 钟武. All rights reserved.
//

typedef void(^SuccessBlock)(void);
typedef void(^FailureBlock)(void);

#import <Foundation/Foundation.h>

@interface URLConnectionDelegateProxy : NSObject <NSURLConnectionDelegate>

- (instancetype)initWithURL:(NSURL *)url success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
