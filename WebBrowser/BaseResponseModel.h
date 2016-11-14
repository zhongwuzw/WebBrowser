//
//  BaseRespnseModel.h
//  ZhihuDaily
//
//  Created by 钟武 on 16/8/3.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface BaseResponseModel : MTLModel <MTLJSONSerializing>

@property (assign, readonly, nonatomic) int errorCode;
@property (copy, readonly, nonatomic) NSString *errorMsg;

- (instancetype)initWithErrorCode:(int)errorCode
                         errorMsg:(NSString *)errorMsg;

@end
