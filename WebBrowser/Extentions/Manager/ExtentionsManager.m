//
//  ExtentionsManager.m
//  WebBrowser
//
//  Created by 钟武 on 2017/10/30.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ExtentionsManager.h"
#import "JavaScriptHelper.h"
#import "PreferenceHelper.h"
#import "BrowserWebView.h"

@implementation ExtentionsManager

+ (void)loadExtentionsIfNeededWhenGotTitleWithWebView:(BrowserWebView *)webView{
    [JavaScriptHelper setNoImageMode:[PreferenceHelper boolForKey:KeyNoImageModeStatus] webView:webView loadPrimaryScript:YES];
    [JavaScriptHelper setLongPressGestureWithWebView:webView];
    [JavaScriptHelper setFindInPageWithWebView:webView];
    
    NSURL *url = [NSURL URLWithString:webView.mainFURL];
    if ([PreferenceHelper boolDefaultYESForKey:KeyBlockBaiduADStatus] && ([url.host isEqualToString:@"m.baidu.com"] || [url.host isEqualToString:@"www.baidu.com"])) {
        [JavaScriptHelper setBaiduADBlockWithWebView:webView];
    }
}

+ (void)loadExtentionsIfNeededWhenMainFrameDidFinishLoad:(BrowserWebView *)webView{
}

+ (void)loadExtentionsIfNeededWhenWebViewDidFinishLoad:(BrowserWebView *)webView{
    if ([PreferenceHelper boolForKey:KeyEyeProtectiveStatus]) {
        [JavaScriptHelper setEyeProtectiveWithWebView:webView colorValue:[PreferenceHelper integerDefault1ForKey:KeyEyeProtectiveColorKind] loadPrimaryScript:YES];
    }
}

+ (void)evaluateScriptButNotLoadExtentionsWithWebView:(BrowserWebView *)webView jsKey:(NSString *)key{
    if ([key isEqualToString:KeyNoImageModeStatus]) {
        [JavaScriptHelper setNoImageMode:[PreferenceHelper boolForKey:KeyNoImageModeStatus] webView:webView loadPrimaryScript:NO];
    }
    else if ([key isEqualToString:KeyEyeProtectiveStatus]){
        
    }
    
}

@end
