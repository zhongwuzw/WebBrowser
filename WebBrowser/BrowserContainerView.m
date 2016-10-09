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

@implementation BrowserContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupWebView];
    }
    return self;
}

- (void)setupWebView{
    NSMutableArray<BrowserWebView *> *browserArray = [[TabManager sharedInstance] getBrowserViewArray];
    for (BrowserWebView *webView in browserArray) {
        [self addSubview:webView];
        webView.frame = CGRectMake(0, 0, self.width, self.height);
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

@end
