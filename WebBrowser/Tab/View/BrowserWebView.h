//
//  BrowserWebView.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrowserWebView, WebModel, WebViewBackForwardList, HomePageView;

typedef void (^WebCompletionBlock)(NSString *, NSError *);
typedef void(^BackForwardListCompletion)(WebViewBackForwardList *);

@protocol WebViewDelegate <NSObject>

@optional

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@end

@interface BrowserWebView : UIWebView<UIWebViewDelegate>

@property (nonatomic, assign) WebModel *webModel;
@property (nonatomic, assign, readonly) BOOL isMainFrameLoaded;
@property (nonatomic, assign, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, retain) HomePageView *homePage;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(WebCompletionBlock)completionHandler;

- (NSString *)mainFURL;
- (NSString *)mainFTitle;
- (void)webViewBackForwardListWithCompletion:(BackForwardListCompletion)completion;

@end
