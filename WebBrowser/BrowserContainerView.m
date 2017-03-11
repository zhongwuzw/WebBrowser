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
#import "NSURL+ZWUtility.h"
#import "DelegateManager+WebViewDelegate.h"

@interface BrowserContainerView () <WebViewDelegate>

@property (nonatomic, readwrite, weak) BrowserWebView *webView;
@property (nonatomic, copy) NSString *restorationWebViewURL;
@property (nonatomic, assign) CGPoint contentOffset;

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

    [self needUpdateWebView];
    
    [[DelegateManager sharedInstance] registerDelegate:self forKeys:@[DelegateManagerBrowserContainerLoadURL,DelegateManagerWebView]];
    [[DelegateManager sharedInstance] addWebViewDelegate:self];
    
    self.restorationIdentifier = NSStringFromClass([self class]);
}

- (void)startLoadWebViewWithURL:(NSString *)url{
    //load restoration url if state preserve enabled
    if (self.restorationWebViewURL) {
        url = self.restorationWebViewURL;
        self.restorationWebViewURL = nil;
    }
    
    if ([[NSURL URLWithString:url] isLocal]) {
        NSURL *originalUrl = [[NSURL URLWithString:url] originalURLFromErrorURL];
        url = originalUrl.absoluteString;
    }
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
                NSNotification *notify = [NSNotification notificationWithName:kWebTabSwitch object:self userInfo:@{@"webView":browserWebView}];
                [Notifier postNotification:notify];
                
            }
            if (!browserWebView.request) {
                [self__ startLoadWebViewWithURL:webModel.url];
            }
        }
    }];
}

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
        {
            if ([self.webView.request.URL isLocal]) {
                NSURL *url = [self.webView.request.URL originalURLFromErrorURL];
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
            }
            else{
                [self.webView reload];
            }
            break;
        }
        case BottomToolBarStopButtonTag:
            [self.webView stopLoading];
            break;
        default:
            break;
    }
}

#pragma mark - WebViewDelegate

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (webView == self.webView) {
        NSURL *url = request.URL;
        if ([url.scheme isEqualToString:@"zwerror"] && [url.host isEqualToString:@"reload"]) {
            [self browserBottomToolBarButtonClickedWithTag:BottomToolBarRefreshButtonTag];
            return NO;
        }
    }

    return YES;
}

#pragma mark - WebViewDelegate

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView)) {
        if (!CGPointEqualToPoint(CGPointZero, self.contentOffset)) {
            [self.scrollView setContentOffset:self.contentOffset animated:NO];
            self.contentOffset = CGPointZero;
        }
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

#pragma mark - Preseving and Restoring State

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.webView.mainFURL forKey:@"webViewURL"];
    CGPoint point = self.scrollView.contentOffset;
    //optimize contentOffset because of contentInset changed when webView scroll
    point.y -= (TOP_TOOL_BAR_HEIGHT - self.scrollView.contentInset.top);
    [coder encodeCGPoint:point forKey:@"webViewContentOffset"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    NSString *webViewURL = [coder decodeObjectForKey:@"webViewURL"];
    
    if (webViewURL && webViewURL.length) {
        self.restorationWebViewURL = webViewURL;
        self.contentOffset = [coder decodeCGPointForKey:@"webViewContentOffset"];
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
