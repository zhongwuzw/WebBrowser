//
//  ErrorPageHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2017/2/18.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ErrorPageHelper.h"
#import "WebServer.h"
#import "NSURL+ZWUtility.h"
#import "BrowserWebView.h"

@implementation ErrorPageHelper

+ (void)registerWithServer:(WebServer *)server{
    [server registerHandlerForMethod:@"GET" module:@"errors" resource:@"error.html" handler:^GCDWebServerResponse *(GCDWebServerRequest *request){
        if (!request.URL.originalURLFromErrorURL) {
            return [[GCDWebServerResponse alloc] initWithStatusCode:404];
        }
        
        int errCode = [request.query[@"code"] intValue];
        NSString *errDescription = request.query[@"description"];
        NSURL *errURLDomain = [NSURL URLWithString:request.query[@"url"]];
        NSString *errDomain = request.query[@"domain"];
        
        if (!(errCode && errDescription && errURLDomain && errDomain)) {
            return [[GCDWebServerResponse alloc] initWithStatusCode:404];
        }
        
        NSString *asset = [[NSBundle mainBundle] pathForResource:@"NetError" ofType:@"html"];
        NSString *actions = @"<button onclick='zwFireReloadButton()'>重试</button>";
        NSDictionary *variables = @{@"error_code": [NSNumber numberWithInt:errCode],
                                   @"error_title": errDescription,
                                   @"short_description": errDomain,
                                   @"actions": actions};
        
        GCDWebServerResponse *response = [[GCDWebServerDataResponse alloc] initWithHTMLTemplate:asset variables:variables];
        [response setValue:@"no cache" forAdditionalHeader:@"Pragma"];
        [response setValue:@"no-cache,must-revalidate" forAdditionalHeader:@"Cache-Control"];
        [response setValue:[NSDate date].description forAdditionalHeader:@"Expires"];
        
        return response;
    }];
    
    [server registerHandlerForMethod:@"GET" module:@"errors" resource:@"NetError.css" handler:^GCDWebServerResponse *(GCDWebServerRequest *request){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"NetError" ofType:@"css"];
        return [GCDWebServerDataResponse responseWithData:[NSData dataWithContentsOfFile:path] contentType:@"text/css"];
    }];
}

+ (void)showPageWithError:(NSError *)error URL:(NSURL *)url inWebView:(BrowserWebView *)webView{
    if (url.isErrorPageURL) {
        return;
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@%@",[[WebServer sharedInstance] base],@"/errors/error.html"]];
    NSArray *queryItems = @[[NSURLQueryItem queryItemWithName:@"url" value:url.absoluteString],
                            [NSURLQueryItem queryItemWithName:@"code" value:[NSString stringWithFormat:@"%ld",(long)error.code]],
                            [NSURLQueryItem queryItemWithName:@"domain" value:error.domain],
                            [NSURLQueryItem queryItemWithName:@"description" value:error.localizedDescription]];
    
    components.queryItems = queryItems;
    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
    
    [webView loadRequest:request];
}

@end
