//
//  URLConnectionDelegateProxy.m
//  WebBrowser
//
//  Created by 钟武 on 2017/10/31.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "URLConnectionDelegateProxy.h"

@interface URLConnectionDelegateProxy ()

@property (nonatomic, copy) SuccessBlock success;
@property (nonatomic, copy) FailureBlock failure;

@end

@implementation URLConnectionDelegateProxy

- (instancetype)initWithURL:(NSURL *)url success:(SuccessBlock)success failure:(FailureBlock)failure{
    if (self = [super init]) {
        _success = success;
        _failure = failure;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        // Async but request on main thread, delegate method also execute on main thread
        NSURLConnection *connection __attribute__((unused)) = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (_failure) {
        dispatch_main_safe_sync(_failure);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [connection cancel];
    if (_success) {
        dispatch_main_safe_sync(_success);
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
