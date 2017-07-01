//
//  BrowserTopToolBar.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/12.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserTopToolBar.h"
#import "TopToolBarShapeView.h"
#import "BrowserHeader.h"
#import "NJKWebViewProgressView.h"
#import "DelegateManager+WebViewDelegate.h"
#import "TabManager.h"

#define SHAPE_VIEW_WIDTH 30
#define SHAPE_VIEW_HEIGHT 44
#define SHAPE_VIEW_Y_OFFSET 5

@interface BrowserTopToolBar () <BrowserWebViewDelegate>

@property (nonatomic, strong) TopToolBarShapeView *shapeView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) UIButton *expandButton;

@end

@implementation BrowserTopToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
        [[DelegateManager sharedInstance] registerDelegate:self forKey:DelegateManagerWebView];
        [[DelegateManager sharedInstance] addWebViewDelegate:self];
        [Notifier addObserver:self selector:@selector(handletabSwitch:) name:kWebTabSwitch object:nil];
    }
    return self;
}

- (void)initializeView{
    self.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    self.shapeView = ({
        TopToolBarShapeView *shapeView = [[TopToolBarShapeView alloc] initWithFrame:CGRectMake(0, 0, self.width - SHAPE_VIEW_WIDTH, self.height - SHAPE_VIEW_HEIGHT)];
        shapeView.center = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + SHAPE_VIEW_Y_OFFSET};
        shapeView.shapeLayer.lineWidth = 2;
        shapeView.shapeLayer.fillColor = UIColorFromRGB(0xE6E6E7).CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeView.bounds cornerRadius:6];
        shapeView.shapeLayer.path = path.CGPath;
        
        [self addSubview:shapeView];
        shapeView;
    });
    
    self.expandButton = ({
        UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:expandButton];
        
        expandButton.frame = CGRectMake(0, 0, 18, 18);
        expandButton.hidden = YES;
        [expandButton addTarget:self action:@selector(handleExpandBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [expandButton setImage:[UIImage imageNamed:@"toolbar_expand_normal"] forState:UIControlStateNormal];
        
        expandButton;
    });
    
    self.progressView = ({
        CGFloat progressBarHeight = 2.f;
        NJKWebViewProgressView *progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, self.height - progressBarHeight, self.width, progressBarHeight)];
        [self addSubview:progressView];
        
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        progressView;
    });
    
    self.progressProxy = ({
        NJKWebViewProgress *progressProxy = [NJKWebViewProgress new];
        
        progressProxy.progressDelegate = self;
        
        progressProxy;
    });
}

- (void)setFrame:(CGRect)frame{
    if (frame.size.height != self.height) {
        CGFloat shapeViewHeight = fabs(frame.size.height * (TOP_TOOL_BAR_HEIGHT - SHAPE_VIEW_HEIGHT) / TOP_TOOL_BAR_HEIGHT);
        self.shapeView.center = (CGPoint){frame.size.width/2, frame.size.height/2 + SHAPE_VIEW_Y_OFFSET};
        
        self.shapeView.transform = CGAffineTransformMakeScale(shapeViewHeight / (TOP_TOOL_BAR_HEIGHT - SHAPE_VIEW_HEIGHT), shapeViewHeight / (TOP_TOOL_BAR_HEIGHT - SHAPE_VIEW_HEIGHT));
        self.expandButton.center = CGPointMake(frame.size.width - 30, frame.size.height / 2 + SHAPE_VIEW_Y_OFFSET);
    }
    self.expandButton.hidden = (frame.size.height != TOP_TOOL_BAR_THRESHOLD);
    
    [super setFrame:frame];
}

- (void)setTopURLOrTitle:(NSString *)urlOrTitle{
    [self.shapeView setTopURLOrTitle:urlOrTitle];
}

#pragma mark - BrowserWebViewDelegate

- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString *)titleName{
    if (IsCurrentWebView(webView)) {
        [self setTopURLOrTitle:titleName];
    }
}

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (IsCurrentWebView(webView) && [self.progressProxy respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.progressProxy webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }

    return YES;
}

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView) && [self.progressProxy respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.progressProxy webViewDidFinishLoad:webView];
    }
}

- (void)webViewDidStartLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView) && [self.progressProxy respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.progressProxy webViewDidFinishLoad:webView];
    }
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    if (IsCurrentWebView(webView) && [self.progressProxy respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.progressProxy webView:webView didFailLoadWithError:error];
    }
}

#pragma mark - Expand Button Handler

- (void)handleExpandBtnClicked:(UIButton *)btn{
    [Notifier postNotification:[NSNotification notificationWithName:kExpandHomeToolBarNotification object:nil]];
}

#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

#pragma mark - kWebTabSwitch notification handler

- (void)handletabSwitch:(NSNotification *)notification{
    BrowserWebView *webView = [notification.userInfo objectForKey:@"webView"];
    if ([webView isKindOfClass:[BrowserWebView class]]) {
        NSString *title = [webView mainFTitle];
        [self setTopURLOrTitle:title];
    }
}

#pragma mark - Dealloc

- (void)dealloc{
    [Notifier removeObserver:self name:kWebTabSwitch object:nil];
}

@end
