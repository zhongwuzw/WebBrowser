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

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

// Arguments 0 and 1 are self and _cmd always
const unsigned int kNumberOfImplicitArgs = 2;

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
            return [(MAIN_FRAME_URL__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_URL)) autorelease];
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
            return [(MAIN_FRAME_TITLE__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_TITLE)) autorelease];
        else
            return nil;
    }
    else
        return nil;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(BrowserWebView *)webView{
    [self performSelector:@selector(webViewDidStartLoad:) onObject:self withArguments:@[webView]];
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    [self performSelector:@selector(webView:didFailLoadWithError:) onObject:self withArguments:@[webView,error]];
}

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    
    if ([HttpHelper canAppHandleURL:url]) {
        return NO;
    }
    
    if ([self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    [self performSelector:@selector(webViewDidFinishLoad:) onObject:self withArguments:@[webView]];
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
    [self performSelector:@selector(webViewForMainFrameDidCommitLoad:) onObject:self withArguments:@[self]];
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
    [self performSelector:@selector(webViewForMainFrameDidFinishLoad:) onObject:self  withArguments:@[self]];
}

#pragma mark - replaced method calling

- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString*)titleName{
        [self performSelector:@selector(webView:gotTitleName:) onObject:self withArguments:@[webView,titleName]];
}

#pragma mark - Method Calling

- (void)performSelector:(SEL)selector onObject:(id)object withArguments:(NSArray *)arguments{
    NSMethodSignature *methodSignature = [object methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
//    [invocation setTarget:object];
    [invocation retainArguments];
    
    NSUInteger numberOfArguments = [methodSignature numberOfArguments];
    for (NSUInteger argumentIndex = kNumberOfImplicitArgs; argumentIndex < numberOfArguments; argumentIndex++) {
        NSUInteger argumentsArrayIndex = argumentIndex - kNumberOfImplicitArgs;
        id argumentObject = [arguments count] > argumentsArrayIndex ? [arguments objectAtIndex:argumentsArrayIndex] : nil;
        
        if (argumentObject && ![argumentObject isKindOfClass:[NSNull class]]) {
            const char *typeEncodingCString = [methodSignature getArgumentTypeAtIndex:argumentIndex];
            if (typeEncodingCString[0] == @encode(id)[0] || typeEncodingCString[0] == @encode(Class)[0] || [self isTollFreeBridgedValue:argumentObject forCFType:typeEncodingCString]) {
                [invocation setArgument:&argumentObject atIndex:argumentIndex];
            } else if (strcmp(typeEncodingCString, @encode(CGColorRef)) == 0 && [argumentObject isKindOfClass:[UIColor class]]) {
                CGColorRef colorRef = [argumentObject CGColor];
                [invocation setArgument:&colorRef atIndex:argumentIndex];
            } else if ([argumentObject isKindOfClass:[NSValue class]]){
                NSValue *argumentValue = (NSValue *)argumentObject;
                
                if (strcmp([argumentValue objCType], typeEncodingCString) != 0) {
                    return;
                }
                
                NSUInteger bufferSize = 0;
                @try {
                    NSGetSizeAndAlignment(typeEncodingCString, &bufferSize, NULL);
                } @catch (NSException *exception) { }
                
                if (bufferSize > 0) {
                    void *buffer = calloc(bufferSize, 1);
                    [argumentValue getValue:buffer];
                    [invocation setArgument:buffer atIndex:argumentIndex];
                    free(buffer);
                }
            }
        }
    }
    [[DelegateManager sharedInstance] callInvocation:invocation withKey:NSStringFromProtocol(@protocol(WebViewDelegate))];
}

- (BOOL)isTollFreeBridgedValue:(id)value forCFType:(const char *)typeEncoding
{
    // See https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/Toll-FreeBridgin/Toll-FreeBridgin.html
#define CASE(cftype, foundationClass) \
if(strcmp(typeEncoding, @encode(cftype)) == 0) { \
return [value isKindOfClass:[foundationClass class]]; \
}
    
    CASE(CFArrayRef, NSArray);
    CASE(CFAttributedStringRef, NSAttributedString);
    CASE(CFCalendarRef, NSCalendar);
    CASE(CFCharacterSetRef, NSCharacterSet);
    CASE(CFDataRef, NSData);
    CASE(CFDateRef, NSDate);
    CASE(CFDictionaryRef, NSDictionary);
    CASE(CFErrorRef, NSError);
    CASE(CFLocaleRef, NSLocale);
    CASE(CFMutableArrayRef, NSMutableArray);
    CASE(CFMutableAttributedStringRef, NSMutableAttributedString);
    CASE(CFMutableCharacterSetRef, NSMutableCharacterSet);
    CASE(CFMutableDataRef, NSMutableData);
    CASE(CFMutableDictionaryRef, NSMutableDictionary);
    CASE(CFMutableSetRef, NSMutableSet);
    CASE(CFMutableStringRef, NSMutableString);
    CASE(CFNumberRef, NSNumber);
    CASE(CFReadStreamRef, NSInputStream);
    CASE(CFRunLoopTimerRef, NSTimer);
    CASE(CFSetRef, NSSet);
    CASE(CFStringRef, NSString);
    CASE(CFTimeZoneRef, NSTimeZone);
    CASE(CFURLRef, NSURL);
    CASE(CFWriteStreamRef, NSOutputStream);
    
#undef CASE
    
    return NO;
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



