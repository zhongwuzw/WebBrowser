//
//  BrowserWebView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserWebView.h"
#import "WebViewHeader.h"

#import <objc/objc-runtime.h>

@implementation BrowserWebView

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
        
        if (completionHandler) {
            completionHandler(result,nil);
        }
    });
}

- (NSString *)mainFURL{
    id webDocumentView = nil;
    id webView = nil;
    id selfid = self;
    if([selfid respondsToSelector:NSSelectorFromString(DOCUMENT_VIEW)])
        webDocumentView = (DOCUMENT_VIEW__PROTO objc_msgSend)(selfid,NSSelectorFromString(DOCUMENT_VIEW));
    else
        return nil;
    
    if(webDocumentView)
    {
        NSString* _web_view = [[LXNormalCall makString:GOT_WEB_VIEW] retain];
        object_getInstanceVariable(webDocumentView,[_web_view cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
        [[webView retain] autorelease];
        [_web_view release];
    }
    else
        return nil;
    
    if(webView)
    {
        if([webView respondsToSelector:[LXNormalCall makCallTitleURL:MAIN_FRAME_URL]])
            return (MAIN_FRAME_URL__PROTO objc_msgSend)(webView, [LXNormalCall makCallTitleURL:MAIN_FRAME_URL]);
        else
            return nil;
    }
    else
        return nil;
}

@end
