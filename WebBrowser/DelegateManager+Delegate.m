//
//  DelegateManager+Delegate.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/9.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "DelegateManager+Delegate.h"

@class FindInPageBar;

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

#pragma mark - FindInPageBarDelegate

- (void)findInPage:(FindInPageBar *)findInPage didTextChange:(NSString *)text{}
- (void)findInPage:(FindInPageBar *)findInPage didFindPreviousWithText:(NSString *)text{}
- (void)findInPage:(FindInPageBar *)findInPage didFindNextWithText:(NSString *)text{}
- (void)findInPageDidPressClose:(FindInPageBar *)findInPage{}

@end
