//
//  TabManager.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "TabManager.h"
#import "BrowserWebView.h"

@interface TabManager ()

@property (nonatomic, strong) NSMutableArray<BrowserWebView *> *browserViewArray;

@end

@implementation TabManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TabManager)

- (NSMutableArray <BrowserWebView *> *)getBrowserViewArray{
    if (!_browserViewArray) {
        _browserViewArray = [NSMutableArray arrayWithCapacity:11];
        BrowserWebView *webView = [BrowserWebView new];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://m.baidu.com"]];
        
        [webView loadRequest:request];
        [_browserViewArray addObject:webView];
    }
    return _browserViewArray;
}

@end
