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

+ (void)setNoImageMode:(BOOL)enabled webView:(BrowserWebView *)webView loadPrimaryScript:(BOOL)needsLoad{
    if (needsLoad) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"NoImageModeHelper" ofType:@"js"];
        NSString *source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        if (source) {
            [webView evaluateJavaScript:source completionHandler:nil];
        }
    }
    
    [webView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.NoImageMode.setEnabled(%d)",enabled] completionHandler:^(NSString *result, NSError *error){
        
    }];
}

@end
