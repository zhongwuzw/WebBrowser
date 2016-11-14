//
//  HTTPErrorCode.h
//  ZhihuDaily
//
//  Created by 钟武 on 16/8/3.
//  Copyright © 2016年 钟武. All rights reserved.
//

#ifndef HTTPErrorCode_h
#define HTTPErrorCode_h

typedef NS_ENUM(NSInteger,ZHErrorType){
    HttpConnectionFailureErrorType = -1000, // 连接服务器失败
    HttpRequestTimedOutErrorType = -1001, // 连接超时
    HttpRequestCancelErrorType = -1002, // 请求被取消
    HttpRequestServerErrorType = -1009, // 服务器端返回错误
    HttpRequestGeneralErrorType = -1010, // 其他网络错误
    HttpRequestParseErrorType = -1011,
};

#endif /* HTTPErrorCode_h */
