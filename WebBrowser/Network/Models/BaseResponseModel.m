//
//  BaseRespnseModel.m
//  ZhihuDaily
//
//  Created by 钟武 on 16/8/3.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BaseResponseModel.h"

@implementation BaseResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{};
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _errorCode = 0;
        _errorMsg = nil;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

- (instancetype)initWithErrorCode:(int)errorCode
                         errorMsg:(NSString *)errorMsg
{
    self = [super init];
    if (self) {
        _errorCode = errorCode;
        _errorMsg = errorMsg;
    }
    return self;
}

@end
