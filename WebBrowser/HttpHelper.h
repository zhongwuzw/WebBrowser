//
//  HttpHelper.h
//  WebBrowser
//
//  Created by 钟武 on 2016/11/10.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpHelper : NSObject

+ (BOOL)canAppHandleURL:(NSURL *)url;

+ (BOOL)isURL:(NSString *)content;

@end
