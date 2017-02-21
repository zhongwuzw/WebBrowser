//
//  DelegateManager+Delegate.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/9.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "DelegateManager+Delegate.h"

@implementation DelegateManager (Delegate)

#pragma mark - WebViewDelegate

- (void)webViewDidStartLoad:(BrowserWebView *)webView{}
- (void)webViewDidFinishLoad:(BrowserWebView *)webView{}
- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{}
- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString*)titleName{}
- (void)webViewForMainFrameDidCommitLoad:(BrowserWebView *)webView{}
- (void)webViewForMainFrameDidFinishLoad:(BrowserWebView *)webView{}


#pragma mark - BrowserContainerLoadURLDelegate

//ContainerView Load URL Delegate
- (void)browserContainerViewLoadWebViewWithSug:(NSString *)text{}

@end
