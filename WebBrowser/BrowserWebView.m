//
//  BrowserWebView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserWebView.h"
#import "WebViewHeader.h"

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
    if ([self respondsToSelector:NSSelectorFromString(DOCUMENT_VIEW)]) {
        
    }
}

@end
