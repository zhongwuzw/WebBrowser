//
//  WebServer.m
//  WebBrowser
//
//  Created by 钟武 on 2017/2/16.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "WebServer.h"
#import <GCDWebServers/GCDWebServers.h>
#import "NSURL+ZWUtility.h"

@interface WebServer ()

@property (nonatomic, strong) GCDWebServer *server;

@end

@implementation WebServer

SYNTHESIZE_SINGLETON_FOR_CLASS(WebServer)

- (NSString *)base{
    return [NSString stringWithFormat:@"http://localhost:%lu",(unsigned long)_server.port];
}

- (instancetype)init{
    if (self = [super init]) {
        _server = [GCDWebServer new];
    }
    return self;
}

- (BOOL)start{
    if (!_server.isRunning) {
        [self.server startWithOptions:@{
                                        GCDWebServerOption_Port: @6800,
                                        GCDWebServerOption_BindToLocalhost: @YES,GCDWebServerOption_AutomaticallySuspendInBackground: @YES
                                        } error:NULL];
    }
    return _server.isRunning;
}

- (void)registerHandlerForMethod:(NSString *)method module:(NSString *)module resource:(NSString *)resource handler:(ServerBlock)handler{
    NSParameterAssert(method);
    NSParameterAssert(module);
    NSParameterAssert(resource);
    NSParameterAssert(handler);
    
    ServerBlock wrappedHandler = ^GCDWebServerResponse *(GCDWebServerRequest *request){
        if (![request.URL isLocal]) {
            return [[GCDWebServerResponse alloc] initWithStatusCode:403];
        }
        
        return handler(request);
    };
    
    [self.server addHandlerForMethod:method path:[NSString stringWithFormat:@"/%@/%@",module,resource] requestClass:[GCDWebServerRequest class] processBlock:wrappedHandler];
}

- (void)registerMainBundleResource:(NSString *)resource module:(NSString *)module{
    NSParameterAssert(resource);
    NSParameterAssert(module);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:nil];
    [self.server addGETHandlerForPath:[NSString stringWithFormat:@"/%@/%@",module,resource.lastPathComponent] filePath:path isAttachment:NO cacheAge:UINT_MAX allowRangeRequests:YES];
}

- (void)registerMainBundleResourcesOfType:(NSString *)type module:(NSString *)module{
    NSParameterAssert(type);
    NSParameterAssert(module);
    
    foreach(path, [NSBundle pathsForResourcesOfType:type inDirectory:[[NSBundle mainBundle] bundlePath]]) {
        [self.server addGETHandlerForPath:[NSString stringWithFormat:@"/%@/%@",module,path.lastPathComponent] filePath:path isAttachment:NO cacheAge:UINT_MAX allowRangeRequests:YES];
    }
}

@end
