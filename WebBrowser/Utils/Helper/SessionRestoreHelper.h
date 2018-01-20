//
//  SessionRestoreHelper.h
//  WebBrowser
//
//  Created by 钟武 on 2017/3/16.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebServer;

@interface SessionRestoreHelper : NSObject

+ (void)registerWithServer:(WebServer *)server;

@end
