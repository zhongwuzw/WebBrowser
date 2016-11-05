//
//  BrowserWebView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserWebView.h"
#import "WebViewHeader.h"

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
    
    [self setScalesPageToFit:YES];
    
    [self setDrawInWebThread];
    
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
        
        if (completionHandler) {
            completionHandler(result,nil);
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
            return (MAIN_FRAME_URL__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_URL));
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
            return (MAIN_FRAME_TITLE__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_TITLE));
        else
            return nil;
    }
    else
        return nil;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if ([self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:self];
    }
}

#pragma mark - replaced method calling

-(void)webViewGotTitle:(NSString*)titleName
{
    if([self.webViewDelegate respondsToSelector:@selector(webView:gotTitleName:)])
    {
        [self.webViewDelegate webView:self gotTitleName:titleName];
    }
}

@end

#pragma mark - Hook Functions

//动态注入

void (*gOrigGotT)(id,SEL, id view, id title, id frame);//原didrecivetitle函数
void (*gOrigNewWin)(id,SEL,id view, id action, id request, id frame, id listener);//decidePolicyForNewWindowAction
void (*gOrigNavAct)(id,SEL,id view,id action,id request,id framename,id listener);//decidePolicyForNavigationAction

//得到title回调
static void webGotTitle(id selfid, SEL sel, id view, id title, id frame) {
    if(![title isKindOfClass:[NSString class]])
        return;
    
    if(gOrigGotT)
        gOrigGotT(selfid,sel,view,title,frame);
    
    
    if(view && [view respondsToSelector:NSSelectorFromString(MAIN_FRAME)])
    {
        id mainFrame = (MAIN_FRAME__PROTO objc_msgSend)(view,NSSelectorFromString(MAIN_FRAME));
        if(mainFrame == frame)
        {
            if(selfid && [selfid respondsToSelector:@selector(webViewGotTitle:)])
                [selfid performSelector:@selector(webViewGotTitle:) withObject:(NSString*)title];
        }
    }
    else
    {
        if(selfid && [selfid respondsToSelector:@selector(webViewGotTitle:)])
            [selfid performSelector:@selector(webViewGotTitle:) withObject:(NSString*)title];
    }
}

//new window 回调
static void webNewWindow(id selfid, SEL sel, id view, id action, id request, id framename, id listener)
{
    if(![request isKindOfClass:[NSURLRequest class]])
        return;
    
    if(![framename isKindOfClass:[NSString class]])
        return;
    
    if(gOrigNewWin)
        gOrigNewWin(selfid, sel , view ,action ,request, framename, listener);
}

//navigation 回调
static void webNavgationAction(id selfid, SEL sel, id view, id action, id request, id frame, id listener)
{
    if(![request isKindOfClass:[NSURLRequest class]])
        return;
    
    NSInteger intNaviType = 0;
    if ([action isKindOfClass:[NSDictionary class]]) {
        id naviType = [((NSDictionary*)action) objectForKey:WEB_ACTION_NAVI_TYPE_KEY];
        if([naviType isKindOfClass:[NSNumber class]])
        {
            intNaviType = [(NSNumber*)naviType integerValue];
        }
    }
    
    if(gOrigNavAct)
        gOrigNavAct(selfid,sel,view,action,request,frame,listener);
}

__attribute__((__constructor__)) static void $(){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Class webViewClass = objc_getClass([UIWEBVIEW cStringUsingEncoding:NSUTF8StringEncoding]);
    
    id classId = webViewClass;
    
    if(classId == nil){
        [pool drain];
        return;
    }
    
    Method origMethod = class_getInstanceMethod(classId, NSSelectorFromString(WEB_GOT_TITLE));
    if (origMethod) {
        gOrigGotT = (void(*)(id,SEL, id, id, id))class_replaceMethod(classId,NSSelectorFromString(WEB_GOT_TITLE), (IMP)&webGotTitle,method_getTypeEncoding(origMethod));
    }
    
    Method origMethodNewWin = class_getInstanceMethod(classId, NSSelectorFromString(WEB_NEW_WINDOW));
    if(origMethodNewWin)
    {
        gOrigNewWin = (void(*)(id,SEL,id,id,id,id,id))class_replaceMethod(classId,NSSelectorFromString(WEB_NEW_WINDOW), (IMP)&webNewWindow, method_getTypeEncoding(origMethodNewWin));
    }
    
    Method origMethodNavAct = class_getInstanceMethod(classId, NSSelectorFromString(WEB_ACTION_NAVIGATION));
    if(origMethodNavAct)
    {
        gOrigNavAct = (void(*)(id,SEL,id,id,id,id,id))class_replaceMethod(classId, NSSelectorFromString(WEB_ACTION_NAVIGATION), (IMP)&webNavgationAction, method_getTypeEncoding(origMethodNavAct));
    }
    
    [pool drain];
}



