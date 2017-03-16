//
//  SessionRestoreHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2017/3/16.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SessionRestoreHelper.h"
#import "WebServer.h"

@implementation SessionRestoreHelper

+ (void)registerWithServer:(WebServer *)server{
    [server registerHandlerForMethod:@"GET" module:@"about" resource:@"sessionrestore" handler:^GCDWebServerResponse *(GCDWebServerRequest *request){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SessionRestore" ofType:@"html"];
        if (path) {
            NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
            return [GCDWebServerDataResponse responseWithHTML:htmlString];
        }
        
        return [GCDWebServerDataResponse responseWithStatusCode:404];
    }];
}

@end
