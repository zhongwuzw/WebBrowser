//
//  BrowserWebView.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrowserWebView;

@protocol WebViewDelegate <NSObject>

@optional

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(BrowserWebView *)webView;
- (void)webViewDidFinishLoad:(BrowserWebView *)webView;
- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString*)titleName;
- (void)webViewForMainFrameDidCommitLoad:(BrowserWebView *)webView;
- (void)webViewForMainFrameDidFinishLoad:(BrowserWebView *)webView;

@end

@interface BrowserWebView : UIWebView<UIWebViewDelegate>

//MRC
@property (nonatomic, unsafe_unretained) id<WebViewDelegate> webViewDelegate;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;

- (NSString *)mainFURL;
- (NSString *)mainFTitle;

@end
