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
#import "HttpHelper.h"
#import "NSURL+ZWUtility.h"
#import "NSString+ZWUtility.h"
#import "NSURLCache+ZWUtility.h"
#import "DelegateManager+WebViewDelegate.h"
#import "SessionData.h"
#import "WebServer.h"
#import "BrowserViewController.h"
#import "HTTPClient.h"
#import "FindInPageBar.h"
#import "MenuHelper.h"
#import "ArrowActivityView.h"
#import "GestureProxy.h"
#import "NSData+ZWUtility.h"
#import "UIAlertAction+ZWUtility.h"

#import <Photos/Photos.h>

static CGFloat const ArrowActivitySize = 30.f;
static NSInteger const ActionSheetTitleMaxLength = 120;
static NSString *const BaiduSearchPath = @"https://m.baidu.com/s?ie=utf-8&word=";

@interface BrowserContainerView () <WebViewDelegate, MenuHelperInterface, BrowserContainerLoadURLDelegate, BrowserWebViewDelegate, FindInPageBarDelegate>

@property (nonatomic, readwrite, weak) BrowserWebView *webView;
@property (nonatomic, weak) UIGestureRecognizer *selectionGestureRecognizer;
@property (nonatomic, strong) GestureProxy *gestureProxy;
@property (nonatomic, assign) CGPoint edgeStartPoint;
@property (nonatomic, strong) ArrowActivityView *arrowActivityView;
@property (nonatomic, assign) BOOL showActivityView;

@end

@implementation BrowserContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupWebView];
    }
    return self;
}

- (UIScrollView *)scrollView{
    return self.webView.scrollView;
}

- (void)setupWebView{
    [TabManager sharedInstance].browserContainerView = self;

    [self restoreWithCompletionHandler:nil animation:NO];
    
    [[DelegateManager sharedInstance] registerDelegate:self forKeys:@[DelegateManagerBrowserContainerLoadURL, DelegateManagerWebView, DelegateManagerFindInPageBarDelegate]];
    [[DelegateManager sharedInstance] addWebViewDelegate:self];
    [Notifier addObserver:self selector:@selector(handleOpenInNewWindow:) name:kOpenInNewWindowNotification object:nil];
    
    [self addScreenEdgePanGesture];
    self.restorationIdentifier = NSStringFromClass([self class]);
}

- (void)startLoadWebViewWithURL:(NSString *)url{
    if ([[NSURL URLWithString:url] isErrorPageURL]) {
        NSURL *originalUrl = [[NSURL URLWithString:url] originalURLFromErrorURL];
        url = originalUrl.absoluteString;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [self.webView loadRequest:request];
}

- (void)handleOpenInNewWindow:(NSNotification *)notify{
    NSURL *url = [notify.userInfo objectForKey:@"url"];
    if ([url isKindOfClass:[NSURL class]]) {
        [self handleOpenInNewWindowWithURL:url];
    }
}

- (void)handleOpenInNewWindowWithURL:(NSURL *)url{
    WEAK_REF(self)
    [[TabManager sharedInstance] addWebModelWithURL:url completion:^{
        STRONG_REF(self_)
        if (self__) {
            [self__ restoreWithCompletionHandler:^(WebModel *webModel, BrowserWebView *webView) {
                NSNotification *notify = [NSNotification notificationWithName:kWebTabSwitch object:self userInfo:@{@"webView":webView}];
                [Notifier postNotification:notify];
            } animation:YES];
        }
    }];
}

- (void)restoreWithCompletionHandler:(TabCompletion)completion animation:(BOOL)animation{
    WEAK_REF(self)
    [[TabManager sharedInstance] setCurWebViewOperationBlockWith:^(WebModel *webModel, BrowserWebView *browserWebView){
        STRONG_REF(self_)
        if (self__) {
            BrowserWebView *oldBrowserView = self__.webView;
            
            browserWebView.frame = CGRectMake(0, 0, self__.width, self__.height);
            
            if (oldBrowserView != browserWebView && [oldBrowserView superview] && animation) {
                browserWebView.transform = CGAffineTransformMakeTranslation(self__.width, 0);
                oldBrowserView.transform = CGAffineTransformIdentity;
                // If the transform property is not the identity transform, the value of frame is undefined and therefore should be ignored.
                oldBrowserView.frame = CGRectMake(0, 0, self__.width, self__.height);
                
                [UIView transitionWithView:self__ duration:.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    oldBrowserView.transform = CGAffineTransformMakeTranslation(- self__.width, 0);
                    [self__ addSubview:browserWebView];
                    browserWebView.transform = CGAffineTransformIdentity;
                    
                }completion:^(BOOL finished){
                    [oldBrowserView removeFromSuperview];
                }];
            }
            else if(oldBrowserView != browserWebView)
            {
                [oldBrowserView removeFromSuperview];
                [self__ addSubview:browserWebView];
            }
            
            self__.webView = browserWebView;
            
            if (!browserWebView.request) {
                SessionData *sessionData = webModel.sessionData;
                if (sessionData) {
                    NSDictionary *originalDic = sessionData.jsonDictionary;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:originalDic options:0 error:NULL];
                    if (jsonData) {
                        NSString *escapedJSON = [jsonData jsonString];
                        escapedJSON = (escapedJSON) ? escapedJSON : @"";
                        NSURL *restoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/about/sessionrestore?history=%@",[[WebServer sharedInstance] base],escapedJSON]];
                        NSURLRequest *request = [NSURLRequest requestWithURL:restoreURL];
                        [browserWebView loadRequest:request];
                    }
                }
                else{
                    [self__ startLoadWebViewWithURL:webModel.url];
                }
            }

            if (completion) {
                completion(webModel, browserWebView);
            }
        }
    }];
}

#pragma mark - ActivityView

- (ArrowActivityView *)arrowActivityView{
    if (!_arrowActivityView) {
        _arrowActivityView = [[ArrowActivityView alloc] initWithFrame:CGRectMake(0, 0, ArrowActivitySize, ArrowActivitySize) kind:ArrowActivityKindLeft];
        [self insertSubview:_arrowActivityView atIndex:0];
    }
    return _arrowActivityView;
}

- (void)addArrowViewWithPoint:(CGPoint)point{
    if (!self.showActivityView) {
        return;
    }
    
    BOOL isLeft = point.x < self.width / 2.0f;
    if (isLeft) {
        self.arrowActivityView.center = CGPointMake(5.f + ArrowActivitySize / 2.0f, self.height / 2);
    }
    else{
        self.arrowActivityView.center = CGPointMake(self.width - ArrowActivitySize / 2.0f - 5.f, self.height / 2.0f);
    }
    
    [self.arrowActivityView setKind:(isLeft) ? ArrowActivityKindLeft : ArrowActivityKindRight];
}

- (void)removeArrowActivityView{
    [self.arrowActivityView removeFromSuperview];
    self.arrowActivityView = nil;
}

- (void)setShowActivityViewIfNeeded{
    NSUInteger num = [[TabManager sharedInstance] numberOfTabs];
    self.showActivityView = (num > 1);
}

- (BOOL)isWindowSwitchLeft{
    if (self.edgeStartPoint.x < self.width / 2.f) {
        return YES;
    }
    return NO;
}

#pragma mark - Handle WebView FindInPage Results

- (void)handleFindInPageWithComponents:(NSString *)url{
    NSDictionary *jsonDic = [url getWebViewJSONDicWithPrefix:@"zwfindinpage://message?json="];
    if (jsonDic) {
        NSNumber *totalResults = [jsonDic objectForKey:@"totalResults"];
        
        NSNumber *currentResult = [jsonDic objectForKey:@"currentResult"];
        
        if (totalResults) {
            [BrowserVC findInPageDidUpdateTotalResults:[totalResults integerValue]];
        }
        if (currentResult) {
            [BrowserVC findInPageDidUpdateCurrentResult:[currentResult integerValue]];
        }
    }
}

#pragma mark - Handle ScreenEdgePan Gesture

- (void)addScreenEdgePanGesture{
    UIPanGestureRecognizer *edgeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePanGesture:)];
    self.gestureProxy = [[GestureProxy alloc] initWithCGPoint:CGPointMake(18, 0)];
    edgeGesture.delegate = _gestureProxy;
    edgeGesture.minimumNumberOfTouches = 1;
    edgeGesture.maximumNumberOfTouches = 1;
    
    [self addGestureRecognizer:edgeGesture];
}

- (void)handleScreenEdgePanGesture:(UIPanGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.backgroundColor = UIColorFromRGB(0x5A5A5A);
        [self setShowActivityViewIfNeeded];
        [self addArrowViewWithPoint:point];
        self.edgeStartPoint = point;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat offset = point.x - _edgeStartPoint.x;
        self.webView.transform = CGAffineTransformMakeTranslation(offset, 0);
        if (self.showActivityView && fabs(offset) >= ArrowActivitySize + 5.f * 2) {
            self.arrowActivityView.centerX = (offset > 0) ? offset / 2.0f : self.width - fabs(offset) / 2.0f;
            if (fabs(offset) > self.width / 2.0f - 50) {
                [self.arrowActivityView setOn:YES];
            }
            else{
                [self.arrowActivityView setOn:NO];
            }
        }
    }
    else {
        [UIView animateWithDuration:.2f animations:^{
           self.webView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            self.backgroundColor = [UIColor clearColor];
            
            if (self.arrowActivityView.isOn) {
                WEAK_REF(self)
                
                void (^block)(WebModel *prev, WebModel *cur) = ^(WebModel *prev, WebModel *cur) {
                    STRONG_REF(self_)
                    if (self__) {
                        [self__ restoreWithCompletionHandler:nil animation:NO];
                    }
                };
                
                [self isWindowSwitchLeft] ? [[TabManager sharedInstance] switchToLeftWindowWithCompletion:block] : [[TabManager sharedInstance] switchToRightWindowWithCompletion:block];
            }
            [self removeArrowActivityView];
        }];
    }
}

#pragma mark - Handle WebView Long Press Gesture

- (void)handleContextMenuWithComponents:(NSString *)url{
    NSDictionary *jsonDic = [url getWebViewJSONDicWithPrefix:@"zwcontextmenu://message?json="];
    if (jsonDic) {
        if (jsonDic[@"handled"]) {
            self.selectionGestureRecognizer.enabled = NO;
            self.selectionGestureRecognizer.enabled = YES;
        }
        
        NSString *urlString = jsonDic[@"link"];
        
        NSString *imageString = jsonDic[@"image"];
        
        [self handleContenxtMenuWithLink:urlString imageURL:imageString];
    }
}

- (void)handleContenxtMenuWithLink:(NSString *)link imageURL:(NSString *)image{
    NSURL *linkURL = [NSURL URLWithString:link];
    NSURL *imageURL = [NSURL URLWithString:image];
    if (!(linkURL || imageURL)) {
        return;
    }
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString *dialogTitle;
    
    if (linkURL) {
        dialogTitle = linkURL.absoluteString;
        UIAlertAction *openNewTabAction = [UIAlertAction actionOpenNewTabWithCompletion:^{
            [self handleOpenInNewWindowWithURL:linkURL];
        }];
        [actionSheetController addAction:openNewTabAction];
        
        UIAlertAction *copyAction = [UIAlertAction actionCopyLinkWithURL:linkURL];
        [actionSheetController addAction:copyAction];
    }
    
    if (imageURL) {
        dialogTitle = imageURL.absoluteString;
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        UIAlertAction *saveImageAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusNotDetermined) {
                [[BrowserVC navigationController].view showHUDAtBottomWithMessage:@"正在保存"];
                [self getImageWithURL:imageURL completion:^(UIImage *image, NSError *error){
                    if (image) {
                        [[BrowserVC navigationController].view showHUDAtBottomWithMessage:@"保存成功"];
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
                    }
                }];
            } else {
                UIAlertController *accessDenied = [UIAlertController alertControllerWithTitle:@"WebBrowser 想要访问照片" message:@"将允许图片保存到照片" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *dismissAction = [UIAlertAction actionDismiss];
                [accessDenied addAction:dismissAction];
                
                UIAlertAction *settingsAction = [UIAlertAction actionSettings];
                [accessDenied addAction:settingsAction];
                
                [BrowserVC presentViewController:accessDenied animated:YES completion:nil];
            }
        }];
        [actionSheetController addAction:saveImageAction];
    }
    
    actionSheetController.title = [dialogTitle ellipsizeWithMaxLength:ActionSheetTitleMaxLength];
    UIAlertAction *cancelAction = [UIAlertAction actionDismiss];
    [actionSheetController addAction:cancelAction];
    
    if (!BrowserVC.presentedViewController) {
        [BrowserVC presentViewController:actionSheetController animated:YES completion:nil];
    }
}

- (void)getImageWithURL:(NSURL *)url completion:(void (^)(UIImage *, NSError *))completion{
    if (!(url && completion)) {
        return;
    }
    
    UIImage *image = nil;
    
    if ((image = [[NSURLCache sharedURLCache] getCachedImageWithURL:url])) {
        completion(image, nil);
        return;
    }
    
    [[HTTPClient sharedInstance] getImageWithURL:url completion:^(UIImage *image, NSError *error){
        if (image) {
            completion(image, nil);
        }
        else{
            completion(nil, error);
        }
    }];
}

#pragma mark - BrowserBottomToolBarButtonClickedDelegate

- (void)browserBottomToolBarButtonClickedWithTag:(BottomToolBarButtonTag)tag{
    switch (tag) {
        case BottomToolBarForwardButtonTag:
            [self.webView goForward];
            break;
        case BottomToolBarBackButtonTag:
            [self.webView goBack];
            break;
        case BottomToolBarRefreshButtonTag:
        {
            NSURL *url = self.webView.request.URL;
            if ([url isErrorPageURL]) {
                NSURL *url = [self.webView.request.URL originalURLFromErrorURL];
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
            }
            else if (!url || [url.absoluteString isEqualToString:@""]){
                WebModel *webModel = [[TabManager sharedInstance] getCurrentWebModel];
                url = [NSURL URLWithString:webModel.url];
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
            }
            else{
                [self.webView reload];
            }
            break;
        }
        case BottomToolBarStopButtonTag:
            [self.webView stopLoading];
            break;
        default:
            break;
    }
}

#pragma mark - WebViewDelegate

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (webView == self.webView) {
        NSURLComponents *url = [NSURLComponents componentsWithString:request.URL.absoluteString];
        if ([url.scheme isEqualToString:@"zwerror"] && [url.host isEqualToString:@"reload"]) {
            [self browserBottomToolBarButtonClickedWithTag:BottomToolBarRefreshButtonTag];
            return NO;
        }
        else if ([url.scheme isEqualToString:@"zwsessionrestore"] && [url.host isEqualToString:@"reload"]){
            //session restore, just reload
            [self.webView reload];
            return NO;
        }
        else if ([url.scheme isEqualToString:@"zwcontextmenu"]){
            [self handleContextMenuWithComponents:url.string];
            return NO;
        }
        else if ([url.scheme isEqualToString:@"zwfindinpage"]){
            [self handleFindInPageWithComponents:url.string];
            return NO;
        }
    }
    return YES;
}

#pragma mark - BrowserContainerLoadURLDelegate

- (void)browserContainerViewLoadWebViewWithSug:(NSString *)text{
    if (!text || !text.length) {
        return;
    }
    
    NSString *urlString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![HttpHelper isURL:urlString]) {
        urlString = [NSString stringWithFormat:BAIDU_SEARCH_URL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
            urlString = [NSString stringWithFormat:@"http://%@",urlString];
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (@available(iOS 11.0, *)) {
        if ([NSStringFromClass([otherGestureRecognizer.delegate class]) containsString:@"_UIKeyboardBasedNonEditableTextSelectionGestureCluster"]) {
            self.selectionGestureRecognizer = otherGestureRecognizer;
        }
    }
    else if ([NSStringFromClass([otherGestureRecognizer.delegate class]) containsString:@"_UIKeyboardBasedNonEditableTextSelectionGestureController"]){
        self.selectionGestureRecognizer = otherGestureRecognizer;
    }
    if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return [NSStringFromClass([otherGestureRecognizer.delegate class]) containsString:@"UIWebBrowserView"];
    }
    
    return NO;
}

#pragma mark - Validating Commands

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(menuHelperFindInBaidu)) {
        return YES;
    }
    if (action == @selector(menuHelperFindInPage)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)findWithText:(NSString *)text function:(NSString *)function{
    text = (text.length) ? text : @"";
    
    NSString *escaped = [[text stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    escaped = (escaped) ? escaped : @"";
    
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.__firefox__.%@(\"%@\")",function,escaped] completionHandler:nil];
}

#pragma mark - MenuHelperInterface Protocol

- (void)menuHelperFindInPage{
    WEAK_REF(self)
    
    [self getWebViewSelectionWithCompletion:^(NSString *result){
        [self_ findWithText:result function:@"find"];
        [BrowserVC findInPageDidSelectForSelection:result];
    }];
}

- (void)menuHelperFindInBaidu{
    WEAK_REF(self)
    [self getWebViewSelectionWithCompletion:^(NSString *result){
        STRONG_REF(self_)
        if (self__) {
            result = [BaiduSearchPath stringByAppendingString:[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURL *url = [NSURL URLWithString:result];
            [self__ handleOpenInNewWindowWithURL:url];
        }
    }];
}

- (void)getWebViewSelectionWithCompletion:(void(^)(NSString *result))completion{
    WEAK_REF(self)
    [self.webView evaluateJavaScript:@"window.__firefox__.getSelection()" completionHandler:^(NSString *result, NSError *error){
        STRONG_REF(self_)
        if (self__ && result.length > 0 && completion) {
            dispatch_main_safe_async(^{
                completion(result);
            })
        }
    }];
}

#pragma mark - FindInPageBarDelegate

- (void)findInPage:(FindInPageBar *)findInPage didTextChange:(NSString *)text{
    [self findWithText:text function:@"find"];
}

- (void)findInPage:(FindInPageBar *)findInPage didFindPreviousWithText:(NSString *)text{
    [self findWithText:text function:@"findPrevious"];
}

- (void)findInPage:(FindInPageBar *)findInPage didFindNextWithText:(NSString *)text{
    [self findWithText:text function:@"findNext"];
}

- (void)findInPageDidPressClose:(FindInPageBar *)findInPage{
    [self.webView evaluateJavaScript:@"window.__firefox__.findDone()" completionHandler:nil];
}

#pragma mark - Dealloc

- (void)dealloc{
    [Notifier removeObserver:self name:kOpenInNewWindowNotification object:nil];
}

@end
