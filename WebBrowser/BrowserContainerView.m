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

#import <Photos/Photos.h>

static NSInteger const ActionSheetTitleMaxLength = 120;
static NSString *const CancelString = @"取消";
static NSString *const BaiduSearchPath = @"https://m.baidu.com/s?ie=utf-8&word=";

@interface BrowserContainerView () <WebViewDelegate, MenuHelperInterface>

@property (nonatomic, readwrite, weak) BrowserWebView *webView;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, weak) UIGestureRecognizer *selectionGestureRecognizer;

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

    [self restoreWithCompletionHandler:nil];
    
    [[DelegateManager sharedInstance] registerDelegate:self forKeys:@[DelegateManagerBrowserContainerLoadURL, DelegateManagerWebView, DelegateManagerFindInPageBarDelegate]];
    [[DelegateManager sharedInstance] addWebViewDelegate:self];
    [Notifier addObserver:self selector:@selector(handleOpenInNewWindow:) name:kOpenInNewWindowNotification object:nil];
    
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
            [self__ restoreWithCompletionHandler:^(WebModel *webModel, BrowserWebView *webView){
                NSNotification *notify = [NSNotification notificationWithName:kWebTabSwitch object:self userInfo:@{@"webView":webView}];
                [Notifier postNotification:notify];
                [[BrowserVC navigationController].view showHUDAtBottomWithMessage:@"已在新窗口中打开"];
            }];
        }
    }];
}

- (void)restoreWithCompletionHandler:(TabCompletion)completion{
    WEAK_REF(self)
    [[TabManager sharedInstance] setCurWebViewOperationBlockWith:^(WebModel *webModel, BrowserWebView *browserWebView){
        STRONG_REF(self_)
        if (self__) {
            [self__.webView removeFromSuperview];
            self__.webView = browserWebView;
            [self__ addSubview:browserWebView];
            [self__ bringSubviewToFront:browserWebView];
            self__.webView.frame = CGRectMake(0, 0, self__.width, self__.height);
            
            if (!browserWebView.request) {
                SessionData *sessionData = webModel.sessionData;
                if (sessionData) {
                    NSDictionary *originalDic = sessionData.jsonDictionary;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:originalDic options:0 error:NULL];
                    if (jsonData) {
                        NSString *escapedJSON = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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

- (NSDictionary *)getWebViewJSONDicWithComponents:(NSString *)url prefix:(NSString *)prefix{
    NSDictionary *jsonDic = nil;
    if ([url hasPrefix:prefix]) {
        NSString *jsonStr = [url substringFromIndex:prefix.length];
        
        jsonStr = [jsonStr stringByRemovingPercentEncoding];
        if (jsonStr) {
            jsonDic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
            if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                return jsonDic;
            }
        }
    }
    return jsonDic;
}

#pragma mark - Handle WebView FindInPage Results

- (void)handleFindInPageWithComponents:(NSString *)url{
    NSDictionary *jsonDic = [self getWebViewJSONDicWithComponents:url prefix:@"zwfindinpage://message?json="];
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

#pragma mark - Handle WebView Long Press Gesture

- (void)handleContextMenuWithComponents:(NSString *)url{
    NSDictionary *jsonDic = [self getWebViewJSONDicWithComponents:url prefix:@"zwcontextmenu://message?json="];
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
        UIAlertAction  *openNewTabAction = [UIAlertAction actionWithTitle:@"在新窗口打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self handleOpenInNewWindowWithURL:linkURL];
        }];
        [actionSheetController addAction:openNewTabAction];
        
        UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"拷贝链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            pasteBoard.URL = linkURL;
            [[BrowserVC navigationController].view showHUDAtBottomWithMessage:@"拷贝成功"];
        }];
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
                
                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:CancelString style:UIAlertActionStyleCancel handler:nil];
                [accessDenied addAction:dismissAction];
                
                UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"打开设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [accessDenied addAction:settingsAction];
                
                [BrowserVC presentViewController:accessDenied animated:YES completion:nil];
            }
        }];
        [actionSheetController addAction:saveImageAction];
    }
    
    actionSheetController.title = [dialogTitle ellipsizeWithMaxLength:ActionSheetTitleMaxLength];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CancelString style:UIAlertActionStyleCancel handler:nil];
    [actionSheetController addAction:cancelAction];
    [BrowserVC presentViewController:actionSheetController animated:YES completion:nil];
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
            if ([self.webView.request.URL isErrorPageURL]) {
                NSURL *url = [self.webView.request.URL originalURLFromErrorURL];
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

#pragma mark - WebViewDelegate

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView)) {
        //pass local url
        if (![webView.mainFURL isLocal] && !CGPointEqualToPoint(CGPointZero, self.contentOffset)) {
            [self.scrollView setContentOffset:self.contentOffset animated:NO];
            self.contentOffset = CGPointZero;
        }
    }
}

#pragma mark - BrowserContainerLoadURLDelegate

- (void)browserContainerViewLoadWebViewWithSug:(NSString *)text{
    if (!text) {
        return;
    }
    NSString *urlString = text;
    if (![HttpHelper isURL:text]) {
        urlString = [NSString stringWithFormat:BAIDU_SEARCH_URL,[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        if (![text hasPrefix:@"http://"] && ![text hasPrefix:@"https://"]) {
            urlString = [NSString stringWithFormat:@"http://%@",text];
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - Preseving and Restoring State

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    CGPoint point = self.scrollView.contentOffset;
    //optimize contentOffset because of contentInset changed when webView scroll
    point.y -= (TOP_TOOL_BAR_HEIGHT - self.scrollView.contentInset.top);
    [coder encodeCGPoint:point forKey:@"webViewContentOffset"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    self.contentOffset = [coder decodeCGPointForKey:@"webViewContentOffset"];
    
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - UIGestureRecognizerDelegate 

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([[otherGestureRecognizer.delegate description] containsString:@"_UIKeyboardBasedNonEditableTextSelectionGestureController"]) {
        self.selectionGestureRecognizer = otherGestureRecognizer;
    }
    if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return [[otherGestureRecognizer.delegate description] containsString:@"UIWebBrowserView"];
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
