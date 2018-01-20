//
//  WebServer.h
//  WebBrowser
//
//  Created by 钟武 on 2017/2/16.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDWebServers/GCDWebServers.h>

typedef GCDWebServerResponse *(^ServerBlock)(GCDWebServerRequest *);

@interface WebServer : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(WebServer)

- (BOOL)start;
- (NSString *)base;
- (void)registerHandlerForMethod:(NSString *)method module:(NSString *)module resource:(NSString *)resource handler:(ServerBlock)handler;
- (void)registerMainBundleResource:(NSString *)resource module:(NSString *)module;
- (void)registerMainBundleResourcesOfType:(NSString *)type module:(NSString *)module;

@end
