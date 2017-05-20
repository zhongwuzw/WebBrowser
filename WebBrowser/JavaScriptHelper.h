//
//  JavaScriptHelper.h
//  WebBrowser
//
//  Created by 钟武 on 2017/2/14.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BrowserWebView;

@interface JavaScriptHelper : NSObject

+ (void)setNoImageMode:(BOOL)enabled webView:(BrowserWebView *)webView loadPrimaryScript:(BOOL)needsLoad;
+ (void)setLongPressGestureWithWebView:(BrowserWebView *)webView;
+ (void)setFindInPageWithWebView:(BrowserWebView *)webView;

@end
