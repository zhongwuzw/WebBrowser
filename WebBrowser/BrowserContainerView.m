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
#import "HttpHelper.h"

@interface BrowserContainerView ()

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
    [TabManager sharedInstance].browserContainerView = self;

//    [self startLoadWebViewWithURL:@"https://m.baidu.com/"];
//    [self startLoadWebViewWithURL:@"http://i.ifeng.com"];
    [self needUpdateWebView];
    
    [[DelegateManager sharedInstance] registerDelegate:self forKeys:@[DelegateManagerWebView,DelegateManagerBrowserContainerLoadURL]];
}

- (void)startLoadWebViewWithURL:(NSString *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [self.webView loadRequest:request];
}

- (void)needUpdateWebView{
    WEAK_REF(self)
    [[TabManager sharedInstance] setCurWebViewOperationBlockWith:^(WebModel *webModel, BrowserWebView *browserWebView){
        STRONG_REF(self_)
        if (self__) {
            if (self__.webView != browserWebView) {
                [self__.webView removeFromSuperview];
                self__.webView = browserWebView;
                [self__ addSubview:browserWebView];
                [self__ bringSubviewToFront:browserWebView];
                self__.webView.frame = CGRectMake(0, 0, self__.width, self__.height);
                self__.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
            }
            if (!browserWebView.request) {
                [self__ startLoadWebViewWithURL:webModel.url];
            }
        }
    }];
}

#pragma mark - WebViewDelegate Method

//#pragma mark - Dealloc
//
//- (void)dealloc{
//    self.webView.webViewDelegate = nil; //BrowserWebView是在MRC下的，所以这里强行设置webViewDelegate为nil
//    self.webView.delegate = nil;
//    self.webView.scrollView.delegate = nil;
//    [self.webView loadHTMLString:@"" baseURL:nil];
//    [self.webView stopLoading];
//    self.webView = nil;
//}

#pragma mark - BrowserBottomToolBarButtonClickedDelegate

- (void)browserBottomToolBarButtonClickedWithTag:(BottomToolBarButtonTag)tag{
    switch (tag) {
        case BottomToolBarForwardButtonTag:
            [self.webView goForward];
            break;
        case BottomToolBarBackButtonTag:
            [self.webView goBack];
            break;
        case BottomToolBarRefreshButtonTag:
            [self.webView reload];
            break;
        case BottomToolBarStopButtonTag:
            [self.webView stopLoading];
            break;
        default:
            break;
    }
}

#pragma mark - BrowserContainerLoadURLDelegate

- (void)browserContainerViewLoadWebViewWithSug:(NSString *)text{
    if (!text) {
        return;
    }
    NSString *urlString = text;
    if (![HttpHelper isURL:text]) {
        urlString = [NSString stringWithFormat:BAIDU_SEARCH_URL,[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        if (![text hasPrefix:@"http://"] && ![text hasPrefix:@"https://"]) {
            urlString = [NSString stringWithFormat:@"http://%@",text];
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
