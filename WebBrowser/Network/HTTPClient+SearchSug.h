//
//  HTTPClient+SearchSug.h
//  WebBrowser
//
//  Created by 钟武 on 2016/11/14.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "HTTPClient.h"

@interface HTTPClient (SearchSug)

- (NSURLSessionDataTask *)getSugWithKeyword:(NSString *)keyword success:(HttpClientSuccessBlock)success fail:(HttpClientFailureBlock)fail;

@end
