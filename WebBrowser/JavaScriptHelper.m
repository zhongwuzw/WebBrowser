//
//  JavaScriptHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2017/2/14.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "JavaScriptHelper.h"
#import "BrowserWebView.h"

@interface JavaScriptHelper ()

@property (nonatomic, strong) NSCache *jsCache;

@end

@implementation JavaScriptHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(JavaScriptHelper)

- (NSCache *)jsCache{
    if (!_jsCache) {
        _jsCache = [[NSCache alloc] init];
    }
    return _jsCache;
}

- (NSString *)getJSSourceWithName:(NSString *)name{
    NSCParameterAssert(name);
    
    NSString *source;
    if ((source = [self.jsCache objectForKey:name])) {
        return source;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"js"];
    source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    [self.jsCache setObject:source forKey:name];
    return source;
}

+ (NSString *)getJSSourceWithName:(NSString *)name{
    return [[self sharedInstance] getJSSourceWithName:name];
}

+ (void)loadJavascriptWithName:(NSString *)name webView:(BrowserWebView *)webView{
    NSString *source = [self getJSSourceWithName:name];
    if (source) {
        [webView evaluateJavaScript:source completionHandler:nil];
    }
}

+ (void)setNoImageMode:(BOOL)enabled webView:(BrowserWebView *)webView loadPrimaryScript:(BOOL)needsLoad{
    if (needsLoad) {
        [self loadJavascriptWithName:@"NoImageModeHelper" webView:webView];
    }
    
    [webView evaluateJavaScript:[NSString stringWithFormat:@"window.__zhongwu__.NoImageMode.setEnabled(%d)",enabled] completionHandler:nil];
}
    
+ (void)setLongPressGestureWithWebView:(BrowserWebView *)webView{
    [self loadJavascriptWithName:@"ContextMenu" webView:webView];
}

+ (void)setFindInPageWithWebView:(BrowserWebView *)webView{
    [self loadJavascriptWithName:@"FindInPage" webView:webView];
}

+ (void)setBaiduADBlockWithWebView:(BrowserWebView *)webView{
    [self loadJavascriptWithName:@"BaiduADBlock" webView:webView];
}

+ (void)setEyeProtectiveWithWebView:(BrowserWebView *)webView colorValue:(NSInteger)colorValue loadPrimaryScript:(BOOL)needsLoad{
    if (needsLoad) {
        [self loadJavascriptWithName:@"EyeProtective" webView:webView];
    }
    
    [webView evaluateJavaScript:[NSString stringWithFormat:@"window.__zhongwu__.EyeProtective.setColorValue(%ld)",(long)colorValue] completionHandler:nil];
}

@end
