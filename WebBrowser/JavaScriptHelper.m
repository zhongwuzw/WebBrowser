//
//  JavaScriptHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2017/2/14.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "JavaScriptHelper.h"
#import "BrowserWebView.h"

@implementation JavaScriptHelper

+ (NSString *)getJSSourceWithName:(NSString *)name{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"js"];
    NSString *source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    return source;
}

+ (void)loadJavascriptWithName:(NSString *)name webView:(BrowserWebView *)webView{
    NSString *source = [self getJSSourceWithName:name];
    if (source) {
        [webView evaluateJavaScript:source completionHandler:nil];
    }
}

+ (void)setNoImageMode:(BOOL)enabled webView:(BrowserWebView *)webView loadPrimaryScript:(BOOL)needsLoad{
    if (needsLoad) {
        [self loadJavascriptWithName:@"NoImageModeHelper" webView:webView];
    }
    
    [webView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.NoImageMode.setEnabled(%d)",enabled] completionHandler:^(NSString *result, NSError *error){
        
    }];
}
    
+ (void)setLongPressGestureWithWebView:(BrowserWebView *)webView{
    [self loadJavascriptWithName:@"ContextMenu" webView:webView];
}

+ (void)setFindInPageWithWebView:(BrowserWebView *)webView{
    [self loadJavascriptWithName:@"FindInPage" webView:webView];
}

@end
