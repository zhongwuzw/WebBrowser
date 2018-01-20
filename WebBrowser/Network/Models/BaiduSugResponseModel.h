//
//  BaiduSugResponseModel.h
//  WebBrowser
//
//  Created by 钟武 on 2016/11/14.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BaseResponseModel.h"

@interface BaiduSugResponseModel : BaseResponseModel

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSArray<NSString *> *sugArray;

@end
