//
//  ExtentionsManager.h
//  WebBrowser
//
//  Created by 钟武 on 2017/10/30.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EyeProtectiveKind) {
    EyeProtectiveKindOfYellow = 1,
    EyeProtectiveKindOfGreen,
    EyeProtectiveKindOfGray,
    EyeProtectiveKindOfOlive
};

@interface ExtentionsManager : NSObject

+ (void)loadExtentionsIfNeededWhenGotTitleWithWebView:(BrowserWebView *)webView;

+ (void)loadExtentionsIfNeededWhenMainFrameDidFinishLoad:(BrowserWebView *)webView;

+ (void)loadExtentionsIfNeededWhenWebViewDidFinishLoad:(BrowserWebView *)webView;

+ (void)evaluateScriptButNotLoadExtentionsWithWebView:(BrowserWebView *)webView jsKey:(NSString *)key;

@end
