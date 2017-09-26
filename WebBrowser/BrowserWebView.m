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
#import "MenuHelper.h"
#import "WebViewBackForwardList.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface BrowserWebView () <MenuHelperInterface>

@property (nonatomic, assign, readwrite) BOOL isMainFrameLoaded;
@property (nonatomic, unsafe_unretained) UIActivityIndicatorView *indicatorView;
@property (nonatomic, unsafe_unretained) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation BrowserWebView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeWebView];
    }
    
    return self;
}

- (void)initializeWebView{
    //don't set backgroundColor to clearColor, prevents black screens from appearing on screenshots
    self.backgroundColor = [UIColor whiteColor];
    
    self.opaque = NO;
    self.delegate = self;
    self.allowsInlineMediaPlayback = YES;
    self.mediaPlaybackRequiresUserAction = NO;
    self.scalesPageToFit = YES;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self setDrawInWebThread];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.hidesWhenStopped = YES;
    
    [self addSubview:activityView];
    
    self.indicatorView = activityView;
    [activityView release];
    
    UILongPressGestureRecognizer *longPressGesture = [UILongPressGestureRecognizer new];
    self.longPressGestureRecognizer = longPressGesture;
    longPressGesture.delegate = [TabManager sharedInstance].browserContainerView;
    [self addGestureRecognizer:longPressGesture];
    [longPressGesture release];
}

- (void)setFrame:(CGRect)frame{
    if (!CGSizeEqualToSize(frame.size, self.size)) {
        self.indicatorView.center = CGPointMake(self.bounds.origin.x + frame.size.width / 2, self.bounds.origin.y + frame.size.height / 2);
    }
    [super setFrame:frame];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(WebCompletionBlock)completionHandler
{
    if (!javaScriptString || [javaScriptString length] == 0) {
        return;
    }
    
    NSString *cpJSString = [javaScriptString copy];
    __block WebCompletionBlock block = [completionHandler copy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* result = [self stringByEvaluatingJavaScriptFromString:cpJSString];
        [cpJSString release];
        
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
    NSAssert([NSThread isMainThread], @"method should called in main thread");
    
    id webView = [self webView];
    
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
    NSAssert([NSThread isMainThread], @"method should called in main thread");
    
    id webView = [self webView];
    
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

- (WebViewBackForwardList *)webViewBackForwardList{
    NSAssert([NSThread isMainThread], @"method should called in main thread");
    
    id webView = [self webView];
    
    if (webView && [webView respondsToSelector:NSSelectorFromString(BACK_FORWARD_LIST)]) {
        id backForwardList = nil;
        backForwardList = [[(BACK_FORWARD_LIST__PROTO objc_msgSend)(webView, NSSelectorFromString(BACK_FORWARD_LIST)) retain] autorelease];
        if (backForwardList) {
            int backCount = 0;
            int forwardCount = 0;
            
            if ([backForwardList respondsToSelector:NSSelectorFromString(BACK_LIST_COUNT)] && [backForwardList respondsToSelector:NSSelectorFromString(FORWARD_LIST_COUNT)]) {
                backCount = (BACK_LIST_COUNT__PROTO objc_msgSend)(backForwardList, NSSelectorFromString(BACK_LIST_COUNT));
                forwardCount = (FORWARD_LIST_COUNT__PROTO objc_msgSend)(backForwardList, NSSelectorFromString(FORWARD_LIST_COUNT));
            }
            
            id backList = nil;
            id forwardList = nil;
            id currentItem = nil;
            if ([backForwardList respondsToSelector:NSSelectorFromString(BACK_LIST_WITH_LIMIT)] && [backForwardList respondsToSelector:NSSelectorFromString(FORWARD_LIST_WITH_LIMIT)] && [backForwardList respondsToSelector:NSSelectorFromString(CURRENT_ITEM)]) {
                backList = [[(BACK_LIST_WITH_LIMIT__PROTO objc_msgSend)(backForwardList, NSSelectorFromString(BACK_LIST_WITH_LIMIT), backCount) retain] autorelease];
                forwardList = [[(FORWARD_LIST_WITH_LIMIT__PROTO objc_msgSend)(backForwardList, NSSelectorFromString(FORWARD_LIST_WITH_LIMIT), forwardCount) retain] autorelease];
                currentItem = [[(CURRENT_ITEM__PROTO objc_msgSend)(backForwardList, NSSelectorFromString(CURRENT_ITEM)) retain] autorelease];
            }
            
            WebViewBackForwardList *list = [[[WebViewBackForwardList alloc] initWithCurrentItem:[self getCurrentItem:currentItem] backList:[self getBackForwardItemsWithArray:backList] forwardList:[self getBackForwardItemsWithArray:forwardList]] autorelease];
            return list;
        }
    }
    
    return nil;
}

- (WebViewHistoryItem *)getCurrentItem:(id)item{
    if (item && [item respondsToSelector:NSSelectorFromString(URL_TITLE)] && [item respondsToSelector:NSSelectorFromString(URL_STRING)]) {
        id urlString = [[(URL_STRING__PROTO objc_msgSend)(item, NSSelectorFromString(URL_STRING)) retain] autorelease];
        id title = [[(URL_TITLE__PROTO objc_msgSend)(item, NSSelectorFromString(URL_TITLE)) retain] autorelease];
        WebViewHistoryItem *hisItem = [[[WebViewHistoryItem alloc] initWithURLString:urlString title:title] autorelease];
        return hisItem;
    }
    return nil;
}

- (NSArray<WebViewHistoryItem *> *)getBackForwardItemsWithArray:(NSArray *)items{
    if (items && items.count > 0) {
        NSMutableArray<WebViewHistoryItem *> *historyItems = [NSMutableArray arrayWithCapacity:items.count];
        [items enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop){
            if ([item respondsToSelector:NSSelectorFromString(URL_TITLE)] && [item respondsToSelector:NSSelectorFromString(URL_STRING)]) {
                @autoreleasepool {
                    id urlString = [[(URL_STRING__PROTO objc_msgSend)(item, NSSelectorFromString(URL_STRING)) retain] autorelease];
                    id title = [[(URL_TITLE__PROTO objc_msgSend)(item, NSSelectorFromString(URL_TITLE)) retain] autorelease];
                    WebViewHistoryItem *hisItem = [[WebViewHistoryItem alloc] initWithURLString:urlString title:title];
                    [historyItems addObject:hisItem];
                    [hisItem release];
                }
            }
        }];
        return historyItems;
    }
    return nil;
}

// get mainFrame
- (id)mainFrameWithWebView:(id)webView{
    if([webView respondsToSelector:NSSelectorFromString(MAIN_FRAME)])
    {
        id mainFrame = [[(MAIN_FRAME__PROTO objc_msgSend)(webView,NSSelectorFromString(MAIN_FRAME)) retain] autorelease];
        return mainFrame;
        
    }
    return nil;
}

// get WebView
- (id)webView{
    id webDocumentView = nil;
    id webView = nil;
    id selfid = self;
    
    if([selfid respondsToSelector:NSSelectorFromString(DOCUMENT_VIEW)]){
        webDocumentView = [[(DOCUMENT_VIEW__PROTO objc_msgSend)(selfid,NSSelectorFromString(DOCUMENT_VIEW)) retain] autorelease];
    }
    else{
        return nil;
    }
    
    if(webDocumentView)
    {
        //也可以使用valueForKey来获取,object_getInstanceVariable方法只能在MRC下执行
        object_getInstanceVariable(webDocumentView,[GOT_WEB_VIEW cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
        [[webView retain] autorelease];
    }
    else{
        return nil;
    }
    
    if(webDocumentView)
    {
        object_getInstanceVariable(webDocumentView,[GOT_WEB_VIEW cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
        [[webView retain] autorelease];
    }
    else{
        return nil;
    }
    
    return webView;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(BrowserWebView *)webView{
    [[DelegateManager sharedInstance] performSelector:@selector(webViewDidStartLoad:) arguments:@[webView] key:DelegateManagerWebView];
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    [[DelegateManager sharedInstance] performSelector:@selector(webView:didFailLoadWithError:) arguments:@[webView,error] key:DelegateManagerWebView];
    [self.indicatorView stopAnimating];
}

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    
    if ([HttpHelper canAppHandleURL:url]) {
        return NO;
    }
    
    BOOL isShouldStart = YES;
    
    NSArray<WeakWebBrowserDelegate *> *delegates = [[DelegateManager sharedInstance] webViewDelegates];
    
    foreach(delegate, delegates) {
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
    
    [self.indicatorView stopAnimating];
}

#pragma mark - private method

//得到title回调
- (void)zwWebView:(id)sender didReceiveTitle:(id)title forFrame:(id)frame{
    if(![title isKindOfClass:[NSString class]])
        return;

    if ([self respondsToSelector:@selector(zwWebView:didReceiveTitle:forFrame:)]) {
        ((void(*)(id, SEL, id, id, id)) objc_msgSend)(self, @selector(zwWebView:didReceiveTitle:forFrame:), sender, title, frame);
    }
    
    id mainFrame = [self mainFrameWithWebView:sender];
    
    if(mainFrame == frame)
    {
        [self webView:self gotTitleName:title];
    }
    
    [self.indicatorView stopAnimating];
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
    self.isMainFrameLoaded = NO;
    
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
    self.isMainFrameLoaded = YES;
    
    [[DelegateManager sharedInstance] performSelector:@selector(webViewForMainFrameDidFinishLoad:) arguments:@[self] key:DelegateManagerWebView];
}

#pragma mark - replaced method calling

- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString*)titleName{
    self.webModel.title = titleName;
    [[DelegateManager sharedInstance] performSelector:@selector(webView:gotTitleName:) arguments:@[webView,titleName] key:DelegateManagerWebView];
}

#pragma mark - frame method

- (void)zwWebView:(id)sender didStartProvisionalLoadForFrame:(id)frame{
    id mainFrame = [self mainFrameWithWebView:sender];
    
    if(mainFrame == frame)
    {
        [self.indicatorView startAnimating];
    }
    
    if ([self respondsToSelector:@selector(zwWebView:didStartProvisionalLoadForFrame:)]) {
        ((void(*)(id, SEL, id, id)) objc_msgSend)(self, @selector(zwWebView:didStartProvisionalLoadForFrame:), sender, frame);
    }
}

#pragma mark - Menu Action

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copy:)) {
        return YES;
    }
    if (action == @selector(selectAll:)) {
        return YES;
    }
    return NO;
}

#pragma mark - Dealloc

- (void)dealloc{
    [self.indicatorView removeFromSuperview];
    self.longPressGestureRecognizer = nil;
    self.indicatorView = nil;
    self.webModel = nil;
    self.delegate = nil;
    self.scrollView.delegate = nil;
    [self stopLoading];
    [self loadHTMLString:@"" baseURL:nil];
    
    DDLogDebug(@"BrowserWebView dealloc");

    [super dealloc];
}

#pragma mark - Initialize

+ (void)initialize{
    if (self == [BrowserWebView class]) {
        @autoreleasepool {
            MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_GOT_TITLE), @selector(zwWebView:didReceiveTitle:forFrame:));
            
            MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_NEW_WINDOW), @selector(zwWebView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:));
            
            MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_ACTION_NAVIGATION), @selector(zwWebView:decidePolicyForNavigationAction:request:frame:decisionListener:));
            
            MethodSwizzle([BrowserWebView class], NSSelectorFromString(MAIN_FRAME_COMMIT_LOAD), @selector(zwMainFrameCommitLoad:));
            
            MethodSwizzle([BrowserWebView class], NSSelectorFromString(MAIN_FRAME_FINISIH_LOAD), @selector(zwMainFrameFinishLoad:));
            
            MethodSwizzle([BrowserWebView class], NSSelectorFromString(FRAME_PROVISIONALLOAD), @selector(zwWebView:didStartProvisionalLoadForFrame:));
        }
    }
}

@end



