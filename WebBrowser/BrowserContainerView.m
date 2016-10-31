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
    
    BrowserWebView *webView = [browserArray firstObject];
    webView.webViewDelegate = self;
    [self addSubview:webView];
    webView.frame = CGRectMake(0, 0, self.width, self.height);
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ifeng.com"]];
    
    [webView loadRequest:request];
    
    self.webView = webView;
}

#pragma mark - WebViewDelegate Method
- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    if ([self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString *)titleName{
    if ([self.webViewDelegate respondsToSelector:@selector(webView:gotTitleName:)]) {
        [self.webViewDelegate webView:webView gotTitleName:titleName];
    }
}

- (void)dealloc{
    self.webView.webViewDelegate = nil; //BrowserWebView是在MRC下的，所以这里强行设置webViewDelegate为nil
    self.webView.delegate = nil;
    self.webView = nil;
}

@end
