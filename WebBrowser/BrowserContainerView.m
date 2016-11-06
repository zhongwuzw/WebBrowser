//
//  BrwoserContentView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/9.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserContainerView.h"
#import "TabManager.h"
#import "BrowserWebView.h"

@interface BrowserContainerView () <WebViewDelegate>

@property (nonatomic, weak) BrowserWebView *webView;

@end

@implementation BrowserContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupWebView];
    }
    return self;
}

- (UIScrollView *)scrollView{
    return self.webView.scrollView;
}

- (void)setupWebView{
    NSMutableArray<BrowserWebView *> *browserArray = [[TabManager sharedInstance] getBrowserViewArray];
    
    self.webView = [browserArray firstObject];
    _webView.webViewDelegate = self;
    [self addSubview:_webView];
    _webView.frame = CGRectMake(0, 0, self.width, self.height);
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self startLoadWebViewWithURL:@"http://www.ifeng.com"];
}

- (void)startLoadWebViewWithURL:(NSString *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [self.webView loadRequest:request];
}

#pragma mark - WebViewDelegate Method
- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    if ([self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

- (void)webViewDidStartLoad:(BrowserWebView *)webView{
    if ([self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewDelegate webViewDidStartLoad:webView];
    }
}

- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString *)titleName{
    if ([self.webViewDelegate respondsToSelector:@selector(webView:gotTitleName:)]) {
        [self.webViewDelegate webView:webView gotTitleName:titleName];
    }
}

- (void)webViewMainFrameDidFinishLoad:(BrowserWebView *)webView{
    if ([self.webViewDelegate respondsToSelector:@selector(webViewMainFrameDidFinishLoad:)]) {
        [self.webViewDelegate webViewMainFrameDidFinishLoad:webView];
    }
}

- (void)webViewMainFrameDidCommitLoad:(BrowserWebView *)webView{
    if ([self.webViewDelegate respondsToSelector:@selector(webViewMainFrameDidCommitLoad:)]) {
        [self.webViewDelegate webViewMainFrameDidCommitLoad:webView];
    }
}

- (void)dealloc{
    self.webView.webViewDelegate = nil; //BrowserWebView是在MRC下的，所以这里强行设置webViewDelegate为nil
    self.webView.delegate = nil;
    self.webView = nil;
}

@end
