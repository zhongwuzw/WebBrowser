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
#import "NSString+ZWUtility.h"
#import "DelegateManager+WebViewDelegate.h"
#import "SessionData.h"
#import "WebServer.h"

@interface BrowserContainerView () <WebViewDelegate>

@property (nonatomic, readwrite, weak) BrowserWebView *webView;
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

    [self restoreWithCompletionHandler:nil];
    
    [[DelegateManager sharedInstance] registerDelegate:self forKeys:@[DelegateManagerBrowserContainerLoadURL,DelegateManagerWebView]];
    [[DelegateManager sharedInstance] addWebViewDelegate:self];
    
    self.restorationIdentifier = NSStringFromClass([self class]);
}

- (void)startLoadWebViewWithURL:(NSString *)url{
    if ([[NSURL URLWithString:url] isErrorPageURL]) {
        NSURL *originalUrl = [[NSURL URLWithString:url] originalURLFromErrorURL];
        url = originalUrl.absoluteString;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [self.webView loadRequest:request];
}

- (void)restoreWithCompletionHandler:(TabCompletion)completion{
    WEAK_REF(self)
    [[TabManager sharedInstance] setCurWebViewOperationBlockWith:^(WebModel *webModel, BrowserWebView *browserWebView){
        STRONG_REF(self_)
        if (self__) {
            [self__.webView removeFromSuperview];
            self__.webView = browserWebView;
            [self__ addSubview:browserWebView];
            [self__ bringSubviewToFront:browserWebView];
            self__.webView.frame = CGRectMake(0, 0, self__.width, self__.height);
            
            if (!browserWebView.request) {
                SessionData *sessionData = webModel.sessionData;
                if (sessionData) {
                    NSDictionary *originalDic = sessionData.jsonDictionary;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:originalDic options:0 error:NULL];
                    if (jsonData) {
                        NSString *escapedJSON = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        escapedJSON = (escapedJSON) ? escapedJSON : @"";
                        NSURL *restoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/about/sessionrestore?history=%@",[[WebServer sharedInstance] base],escapedJSON]];
                        NSURLRequest *request = [NSURLRequest requestWithURL:restoreURL];
                        [browserWebView loadRequest:request];
                    }
                }
                else{
                    [self__ startLoadWebViewWithURL:webModel.url];
                }
            }

            if (completion) {
                completion(webModel, browserWebView);
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
            if ([self.webView.request.URL isErrorPageURL]) {
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
        else if ([url.scheme isEqualToString:@"zwsessionrestore"] && [url.host isEqualToString:@"reload"]){
            //session restore, just reload
            [self.webView reload];
            return NO;
        }
    }

    return YES;
}

#pragma mark - WebViewDelegate

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView)) {
        //pass local url
        if (![webView.mainFURL isLocal] && !CGPointEqualToPoint(CGPointZero, self.contentOffset)) {
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
    CGPoint point = self.scrollView.contentOffset;
    //optimize contentOffset because of contentInset changed when webView scroll
    point.y -= (TOP_TOOL_BAR_HEIGHT - self.scrollView.contentInset.top);
    [coder encodeCGPoint:point forKey:@"webViewContentOffset"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    self.contentOffset = [coder decodeCGPointForKey:@"webViewContentOffset"];
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
