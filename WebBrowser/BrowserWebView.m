//
//  BrowserWebView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserWebView.h"
#import "WebViewHeader.h"
#import "HttpHelper.h"
#import "TabManager.h"
#import "DelegateManager+WebViewDelegate.h"

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@interface BrowserWebView ()
@end

@implementation BrowserWebView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeWebView];
    }
    
    return self;
}

- (void)initializeWebView{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.delegate = self;
    self.allowsInlineMediaPlayback = YES;
    self.mediaPlaybackRequiresUserAction = NO;
    
    [self setScalesPageToFit:YES];
    
    [self setDrawInWebThread];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(WebCompletionBlock)completionHandler
{
    if (!javaScriptString || [javaScriptString length] == 0) {
        return;
    }
    __block WebCompletionBlock block = [completionHandler copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* result = [[self stringByEvaluatingJavaScriptFromString:javaScriptString] autorelease];
        
        if (block) {
            block(result,nil);
            [block release];
            block = nil;
        }
    });
}

- (void)setDrawInWebThread{
    if([self respondsToSelector:NSSelectorFromString(DRAW_IN_WEB_THREAD)])
        (DRAW_IN_WEB_THREAD__PROTO objc_msgSend)(self,NSSelectorFromString(DRAW_IN_WEB_THREAD),YES);
    if([self respondsToSelector:NSSelectorFromString(DRAW_CHECKERED_PATTERN)])
        (DRAW_CHECKERED_PATTERN__PROTO objc_msgSend)(self, NSSelectorFromString(DRAW_CHECKERED_PATTERN),YES);
}

- (NSString *)mainFURL{
    id webDocumentView = nil;
    id webView = nil;
    id selfid = self;
    if([selfid respondsToSelector:NSSelectorFromString(DOCUMENT_VIEW)])
        webDocumentView = (DOCUMENT_VIEW__PROTO objc_msgSend)(selfid,NSSelectorFromString(DOCUMENT_VIEW));
    else
        return nil;
    
    if(webDocumentView)
    {
        //也可以使用valueForKey来获取,object_getInstanceVariable方法只能在MRC下执行
        object_getInstanceVariable(webDocumentView,[GOT_WEB_VIEW cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
        [[webView retain] autorelease];
    }
    else
        return nil;
    
    if(webView)
    {
        if([webView respondsToSelector:NSSelectorFromString(MAIN_FRAME_URL)])
            return [[(MAIN_FRAME_URL__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_URL)) retain] autorelease];
        else
            return nil;
    }
    else
        return nil;
}

- (NSString *)mainFTitle
{
    id webDocumentView = nil;
    id webView = nil;
    id selfid = self;
    if([selfid respondsToSelector:NSSelectorFromString(DOCUMENT_VIEW)])
        webDocumentView = (DOCUMENT_VIEW__PROTO objc_msgSend)(selfid, NSSelectorFromString(DOCUMENT_VIEW));
    else
        return nil;
    
    if(webDocumentView)
    {
        object_getInstanceVariable(webDocumentView,[GOT_WEB_VIEW cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
    }
    else
        return nil;
    
    if(webView)
    {
        if([webView respondsToSelector:NSSelectorFromString(MAIN_FRAME_TITLE)])
            return [[(MAIN_FRAME_TITLE__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_TITLE)) retain] autorelease];
        else
            return nil;
    }
    else
        return nil;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(BrowserWebView *)webView{
    [[DelegateManager sharedInstance] performSelector:@selector(webViewDidStartLoad:) arguments:@[webView] key:DelegateManagerWebView];
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    [[DelegateManager sharedInstance] performSelector:@selector(webView:didFailLoadWithError:) arguments:@[webView,error] key:DelegateManagerWebView];
}

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    
    if ([HttpHelper canAppHandleURL:url]) {
        return NO;
    }
    
    BOOL isShouldStart = YES;
    
    NSArray<WeakWebBrowserDelegate *> *delegates = [[DelegateManager sharedInstance] webViewDelegates];
    for (WeakWebBrowserDelegate *delegate in delegates) {
        if ([delegate.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
            isShouldStart = [delegate.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
            if (!isShouldStart) {
                return isShouldStart;
            }
        }
    }
    
    return isShouldStart;
}

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    [[DelegateManager sharedInstance] performSelector:@selector(webViewDidFinishLoad:) arguments:@[webView] key:DelegateManagerWebView];
}

#pragma mark - private method

//得到title回调
- (void)zwWebView:(id)sender didReceiveTitle:(id)title forFrame:(id)frame{
    if(![title isKindOfClass:[NSString class]])
        return;

    if ([self respondsToSelector:@selector(zwWebView:didReceiveTitle:forFrame:)]) {
        ((void(*)(id, SEL, id, id, id)) objc_msgSend)(self, @selector(zwWebView:didReceiveTitle:forFrame:), sender, title, frame);
    }
    
    
    if([sender respondsToSelector:NSSelectorFromString(MAIN_FRAME)])
    {
        id mainFrame = (MAIN_FRAME__PROTO objc_msgSend)(sender,NSSelectorFromString(MAIN_FRAME));
        if(mainFrame == frame)
        {
            [self webView:self gotTitleName:title];
        }
    }
    else
    {
        [self webView:self gotTitleName:title];
    }
}

#pragma mark - decidePolicy method

//new window 回调
- (void)zwWebView:(id)webView decidePolicyForNewWindowAction:(id)actionInformation request:(id)request newFrameName:(id)frameName decisionListener:(id)listener{
    if ([self respondsToSelector:@selector(zwWebView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:)]) {
        ((void(*)(id, SEL, id, id, id, id, id)) objc_msgSend)(self, @selector(zwWebView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:), webView, actionInformation, request, frameName, listener);
    }
    
    if(![request isKindOfClass:[NSURLRequest class]])
        return;
    
    if(![frameName isKindOfClass:[NSString class]])
        return;
    
}

//navigation 回调
- (void)zwWebView:(id)webView decidePolicyForNavigationAction:(id)actionInformation request:(id)request frame:(id)frame decisionListener:(id)listener{
    if(![request isKindOfClass:[NSURLRequest class]])
        return;
    
    NSInteger intNaviType = 0;
    if ([actionInformation isKindOfClass:[NSDictionary class]]) {
        id naviType = [((NSDictionary*)actionInformation) objectForKey:WEB_ACTION_NAVI_TYPE_KEY];
        if([naviType isKindOfClass:[NSNumber class]])
        {
            intNaviType = [(NSNumber*)naviType integerValue];
        }
    }
    
    if([self respondsToSelector:@selector(zwWebView:decidePolicyForNavigationAction:request:frame:decisionListener:)])
        ((void(*)(id, SEL, id, id, id, id, id)) objc_msgSend)(self, @selector(zwWebView:decidePolicyForNavigationAction:request:frame:decisionListener:), webView, actionInformation, request, frame, listener);
}

#pragma mark - main frame load functions
//webViewMainFrameDidCommitLoad:
- (void)zwMainFrameCommitLoad:(id)arg1
{
    if([self respondsToSelector:@selector(zwMainFrameCommitLoad:)])
    {
        ((void(*)(id, SEL, id)) objc_msgSend)(self, @selector(zwMainFrameCommitLoad:),arg1);
    }
    
    [self webViewForMainFrameDidCommitLoad:self];
}

- (void)webViewForMainFrameDidCommitLoad:(BrowserWebView *)webView{
    self.webModel.url = [self mainFURL];
    [[DelegateManager sharedInstance] performSelector:@selector(webViewForMainFrameDidCommitLoad:) arguments:@[self] key:DelegateManagerWebView];
}

//webViewMainFrameDidFinishLoad:
- (void)zwMainFrameFinishLoad:(id)arg1
{
    if([self respondsToSelector:@selector(zwMainFrameFinishLoad:)])
    {
        ((void(*)(id, SEL, id)) objc_msgSend)(self, @selector(zwMainFrameFinishLoad:),arg1);
    }
    
    [self webViewForMainFrameDidFinishLoad:self];
}

- (void)webViewForMainFrameDidFinishLoad:(BrowserWebView *)webView{
    [[DelegateManager sharedInstance] performSelector:@selector(webViewForMainFrameDidFinishLoad:) arguments:@[self] key:DelegateManagerWebView];
}

#pragma mark - replaced method calling

- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString*)titleName{
    self.webModel.title = titleName;
    [[DelegateManager sharedInstance] performSelector:@selector(webView:gotTitleName:) arguments:@[webView,titleName] key:DelegateManagerWebView];
}

- (void)dealloc{
    self.webModel = nil;
    self.delegate = nil;
    self.scrollView.delegate = nil;
    [self stopLoading];
    [self loadHTMLString:@"" baseURL:nil];
    
    [super dealloc];
}

@end

__attribute__((__constructor__)) static void $(){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_GOT_TITLE), @selector(zwWebView:didReceiveTitle:forFrame:));
    
    MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_NEW_WINDOW), @selector(zwWebView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:));
    
    MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_ACTION_NAVIGATION), @selector(zwWebView:decidePolicyForNavigationAction:request:frame:decisionListener:));

    MethodSwizzle([BrowserWebView class], NSSelectorFromString(MAIN_FRAME_COMMIT_LOAD), @selector(zwMainFrameCommitLoad:));
    
    MethodSwizzle([BrowserWebView class], NSSelectorFromString(MAIN_FRAME_FINISIH_LOAD), @selector(zwMainFrameFinishLoad:));
    
    [pool drain];
}



