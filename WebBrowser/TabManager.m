//
//  TabManager.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "TabManager.h"
#import "BrowserWebView.h"
#import "BrowserViewController.h"

@implementation WebModel
@end

@interface TabManager ()

@property (nonatomic, strong) NSMutableArray<BrowserWebView *> *browserViewArray;

@end

@implementation TabManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TabManager)

- (NSMutableArray<BrowserWebView *> *)browserViewArray{
    if (!_browserViewArray) {
        _browserViewArray = [NSMutableArray arrayWithCapacity:11];
        BrowserWebView *webView = [BrowserWebView new];
        webView.scrollView.delegate = [BrowserViewController sharedInstance];
        //        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://m.baidu.com"]];
        
        [_browserViewArray addObject:webView];
    }
    return _browserViewArray;
}

- (NSArray<WebModel *> *)getWebViewSnapshot{
    UIImage *image = [self.browserViewArray[0] snapshotForBrowserWebView];
    WebModel *webModel = [WebModel new];
    webModel.title = @"百度一下";
    webModel.image = image;
    
    NSArray<WebModel *> *webArray = [NSArray arrayWithObjects:webModel, webModel,webModel, webModel, webModel,webModel, webModel, webModel,webModel, nil];
    
    return webArray;
}

@end
