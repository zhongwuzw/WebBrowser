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
#import "ErrorPageHelper.h"
#import "BrowserContainerView.h"
#import "SessionData.h"
#import "WebViewBackForwardList.h"
#import "HistorySQLiteManager.h"
#import "ExtentionsManager.h"
#import "PreferenceHelper.h"
#import "URLConnectionDelegateProxy.h"
#import "UIAlertAction+ZWUtility.h"

#import <CommonCrypto/CommonDigest.h>

typedef void(^JSBlock)(BrowserWebView *);

static NSString *const MULTI_WINDOW_FILE_NAME    = @"multiWindowHis.plist";
static NSString *const MY_HISTORY_DATA_KEY       = @"multiWindowHisData";
static NSString *const MULTI_WINDOW_IMAGE_FOLDER = @"multiWindowImages";

static NSString *const KEY_WEB_TITLE        = @"KEY_WEB_TITLE";
static NSString *const KEY_WEB_URL          = @"KEY_WEB_URL";
static NSString *const KEY_WEB_IMAGE        = @"KEY_WEB_IMAGE";
static NSString *const KEY_WEB_IMAGE_URL    = @"KEY_WEB_IMAGE_URL";
static NSString *const KEY_WEB_SESSION_DATA    = @"KEY_WEB_SESSION_DATA";

static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

#ifdef DEBUG
#define QueueCheck(shouldSyncQueue) do {                                                       \
TabManager *manager = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);                                            \
assert((shouldSyncQueue ? manager == self : manager != self) && "operate on webModelArray needs in sync queue");   \
} while (0)
#else
#define QueueCheck(shouldSyncQueue)
#endif

@implementation WebModel

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectOfClass:[NSString class] forKey:KEY_WEB_TITLE];
        _url = [aDecoder decodeObjectOfClass:[NSString class] forKey:KEY_WEB_URL];
        _imageKey = [aDecoder decodeObjectOfClass:[NSString class] forKey:KEY_WEB_IMAGE_URL];
        _sessionData = [aDecoder decodeObjectOfClass:[SessionData class] forKey:KEY_WEB_SESSION_DATA];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:KEY_WEB_TITLE];
    [aCoder encodeObject:self.url forKey:KEY_WEB_URL];
    [aCoder encodeObject:self.imageKey forKey:KEY_WEB_IMAGE_URL];
    [aCoder encodeObject:self.sessionData forKey:KEY_WEB_SESSION_DATA];
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

@end

@interface TabManager () <BrowserWebViewDelegate>

@property (nonatomic, strong) NSMutableArray<WebModel *> *webModelArray;
@property (nonatomic, copy)   NSString *filePath;
@property (nonatomic, copy)   NSString *imagesFolderPath;
@property (nonatomic, strong) dispatch_queue_t synchQueue;

@end

@implementation TabManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TabManager)

- (instancetype)init{
    if (self = [super init]) {
        _filePath = [DocumentPath stringByAppendingPathComponent:MULTI_WINDOW_FILE_NAME];
        _imagesFolderPath = [DocumentPath stringByAppendingPathComponent:MULTI_WINDOW_IMAGE_FOLDER];
        
        NSString *queueName = [NSString stringWithFormat:@"com.zhongwu.TabManager-%@", [[NSUUID UUID] UUIDString]];
        _synchQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_synchQueue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
        
        _webModelArray = [NSMutableArray arrayWithCapacity:4];
        [self loadWebModelArray];
        
        [self registerObserver];
    }
    
    return self;
}

- (void)registerObserver{
    [Notifier addObserver:self
                                             selector:@selector(clearMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [Notifier addObserver:self
                                             selector:@selector(cleanDisk)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [Notifier addObserver:self
                                             selector:@selector(backgroundCleanDisk)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [Notifier addObserver:self selector:@selector(noImageModeChanged) name:kNoImageModeChanged object:nil];
    [Notifier addObserver:self selector:@selector(eyeProtectiveModeChanged) name:kEyeProtectiveModeChanged object:nil];
    
    [[DelegateManager sharedInstance] registerDelegate:self forKey:DelegateManagerWebView];
}

- (BOOL)isCurrentWebView:(BrowserWebView *)webView{
    if (webView == self.browserContainerView.webView) {
        return YES;
    }
    return NO;
}

- (NSArray<NSString *> *)getBackForwardListURL:(WebViewBackForwardList *)list{
    NSMutableArray *array = [NSMutableArray array];
    [list.backList enumerateObjectsUsingBlock:^(WebViewHistoryItem *item, NSUInteger idx, BOOL *stop){
        NSString *url = (item.URLString ? item.URLString : @"");
        [array addObject:url];
    }];
    
    if (list.currentItem) {
        NSString *url = (list.currentItem.URLString ? list.currentItem.URLString : @"");
        [array addObject:url];
    }
    
    [list.forwardList enumerateObjectsUsingBlock:^(WebViewHistoryItem *item, NSUInteger idx, BOOL *stop){
        NSString *url = (item.URLString ? item.URLString : @"");
        [array addObject:url];
    }];
    
    return [array copy];
}

- (void)loadWebModelArray{
    dispatch_async(_synchQueue, ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
            NSData *data = [NSData dataWithContentsOfFile:self.filePath options:NSDataReadingUncached error:nil];
            if (data) {
                NSKeyedUnarchiver *unarchiver;
                @try {
                    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                    NSArray<WebModel *> *array = [unarchiver decodeObjectForKey:MY_HISTORY_DATA_KEY];
                    
                    if (array && [array isKindOfClass:[NSArray<WebModel *> class]] && array.count > 0) {
                        [self.webModelArray addObjectsFromArray:array];
                    }
                    else{
                        [self setDefaultWebArray];
                    }
                } @catch (NSException *exception) {
                    DDLogError(@"tab unarchive error");
                    [self setDefaultWebArray];
                } @finally {
                    [unarchiver finishDecoding];
                }
                
            }
            else
                [self setDefaultWebArray];
        }
        else
            [self setDefaultWebArray];
    });
}

- (void)saveWebModelToDisk{
    NSUInteger count = _webModelArray.count;
    [_webModelArray enumerateObjectsUsingBlock:^(WebModel *model, NSUInteger idx, BOOL *stop){
        BrowserWebView *webView = model.webView;
        
        if (webView) {
            // Fix dead lock between synchQueue and main queue
            dispatch_main_safe_async(^{
                [webView webViewBackForwardListWithCompletion:^(WebViewBackForwardList *backForwardList){
                    if (!backForwardList) {
                        return ;
                    }
                    dispatch_async(self.synchQueue, ^{
                        NSArray *urls = [self getBackForwardListURL:backForwardList];
                        NSInteger currentPage = -backForwardList.forwardList.count;
                        model.sessionData = [[SessionData alloc] initWithCurrentPage:currentPage urls:urls];
                    });
                }];
            });
        }
        
        if (idx + 1 == count) {
            // Fix dead lock between synchQueue and main queue
            dispatch_main_safe_async(^{
                dispatch_async(self.synchQueue, ^{
                    NSMutableData *data = [NSMutableData data];
                    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                    [archiver encodeObject:self.webModelArray forKey:MY_HISTORY_DATA_KEY];
                    [archiver finishEncoding];
                    
                    [data writeToFile:self.filePath atomically:YES];
                });
            })
        }
    }];
}

//save webModel, public API
- (void)saveWebModelData{
    dispatch_async(self.synchQueue, ^{
        [self.webModelArray enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
            @autoreleasepool {
                if (webModel.webView) {
                    NSString *key = [NSString stringWithFormat:@"%f%@%@",[[NSDate date] timeIntervalSince1970],webModel.url,webModel.title];
                    [self storeImage:webModel.image forKey:key];
                    webModel.imageKey = key;
                }
            }
        }];
        
        [self saveWebModelToDisk];
    });
}

- (void)setDefaultWebArray{
    [_webModelArray removeAllObjects];
    [_webModelArray addObject:[self getDefaultWebModel]];
}

- (WebModel *)getDefaultWebModel{
    WebModel *webModel = [WebModel new];
    webModel.title = DEFAULT_CARD_CELL_TITLE;
    webModel.url = DEFAULT_CARD_CELL_URL;
    
    return webModel;
}

- (WebModel *)getCurrentWebModel{
    QueueCheck(NO);
    
    __block WebModel *webModel = nil;
    dispatch_sync(self.synchQueue, ^{
        webModel = [self.webModelArray lastObject];
    });
    
    return webModel;
}

- (void)setMultiWebViewOperationBlockWith:(MultiWebViewOperationBlock)block{
    dispatch_async(self.synchQueue, ^{
        [self.webModelArray enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
            webModel.isImageProcessed = NO;
            UIImage *image = [webModel.webView snapshotForBrowserWebView];
            if (!image) {
                image = [self imageFromDiskCacheForKey:webModel.imageKey];
                if (image) {
                    webModel.isImageProcessed = YES;
                }
            }
            if (!image) {
                image = ([webModel.url isEqualToString:DEFAULT_CARD_CELL_URL]) ? [UIImage imageNamed:DEFAULT_CARD_CELL_IMAGE] : [UIImage imageNamed:DEFAULT_IMAGE];
            }
            webModel.image = image;
        }];
        dispatch_main_safe_async(^{
            if (block) {
                block([self.webModelArray copy]);
            }
        })
    });
}

- (void)setCurWebViewOperationBlockWith:(CurWebViewOperationBlock)block{
    WEAK_REF(self)
    dispatch_async(self.synchQueue, ^{
        __block BrowserWebView *browserWebView;
        WebModel *curModel = [self_.webModelArray lastObject];
        if (!curModel.webView) {
            dispatch_main_safe_async(^{
                browserWebView = [BrowserWebView new];
                browserWebView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_HEIGHT, 0, BOTTOM_TOOL_BAR_HEIGHT, 0);
                browserWebView.scrollView.delegate = BrowserVC;
                
                dispatch_async(self_.synchQueue, ^{
                    self_.webModelArray.lastObject.webView = browserWebView;
                    browserWebView.webModel = curModel;
                });
                dispatch_main_safe_async(^{
                    if (block) {
                        block(curModel, browserWebView);
                    }
                })
            })
        }
        else {
            browserWebView = curModel.webView;
            dispatch_main_safe_async(^{
                if (block) {
                    block(curModel, browserWebView);
                }
            })
        }
    });
}

- (void)updateWebModelArray:(NSArray<WebModel *> *)webArray{
    [self updateWebModelArray:webArray completion:nil];
}

- (void)updateWebModelArray:(NSArray<WebModel *> *)webArray completion:(WebBrowserNoParamsBlock)block{
    NSArray *copyArray = [webArray copy];
    
    dispatch_async(self.synchQueue, ^{
        if (!copyArray.count) {
            [self setDefaultWebArray];
        }
        else
        {
            [self.webModelArray removeAllObjects];
            [self.webModelArray addObjectsFromArray:copyArray];
        }
        
        
        if (block) {
            dispatch_main_safe_async(^{
                block();
            })
        }
    });
}

- (void)switchToLeftOrRight:(BOOL)isLeft completion:(SwitchOperationBlock)block{
    dispatch_async(self.synchQueue, ^{
        if (self.webModelArray.count <= 1) {
            return ;
        }
        
        WebModel *prevWebModel = [self.webModelArray lastObject];
        
        if (isLeft) {
            [self.webModelArray insertObject:prevWebModel atIndex:0];
            [self.webModelArray removeLastObject];
        }
        else {
            [self.webModelArray addObject:[self.webModelArray firstObject]];
            [self.webModelArray removeObjectAtIndex:0];
        }
        
        WebModel *curWebModel = [self.webModelArray lastObject];
        
        if (block) {
            dispatch_main_safe_async(^{
                block(prevWebModel, curWebModel);
            })
        }
    });
}

- (void)switchToLeftWindowWithCompletion:(SwitchOperationBlock)block{
    [self switchToLeftOrRight:YES completion:block];
}

- (void)switchToRightWindowWithCompletion:(SwitchOperationBlock)block{
    [self switchToLeftOrRight:NO completion:block];
}

- (void)addWebModelWithURL:(NSURL *)url completion:(WebBrowserNoParamsBlock)completion{
    if (!url) {
        return;
    }
    
    dispatch_async(self.synchQueue, ^{
        WebModel *webModel = [WebModel new];
        webModel.url = url.absoluteString;
        
        [self.webModelArray addObject:webModel];
        
        if (completion) {
            completion();
        }
    });
}

- (void)stopLoadingCurrentWebView{
    dispatch_main_safe_async(^{
        [self.browserContainerView.webView stopLoading];
    })
}

- (NSUInteger)numberOfTabs{
    __block NSUInteger num;
    dispatch_sync(self.synchQueue, ^{
        num = self.webModelArray.count;
    });
    return num;
}

#pragma mark - Disk Image Method

- (void)storeImage:(UIImage *)image forKey:(NSString *)key{
    if (!image || !key) {
        return;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, (CGFloat)1.0f);
    
    if (!data) {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:self.imagesFolderPath]) {
        [fileManager createDirectoryAtPath:self.imagesFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString *cachePathForKey = [self defaultCachePathForKey:key];
    
    [fileManager createFileAtPath:cachePathForKey contents:data attributes:nil];
}

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key{
    NSString *defaultPath = [self defaultCachePathForKey:key];

    UIImage *image = [UIImage imageWithContentsOfFile:defaultPath];
    
    if (image) {
        return  image;
    }
    return nil;
}

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.imagesFolderPath];
}

- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x.jpg",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

#pragma mark - Notification Method

- (void)clearMemory{
    dispatch_async(self.synchQueue, ^{
        //remove olddest unused webView
        __block WebModel *toDeleteWebModel;
        [self.webModelArray enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
            //don't remove newest webView
            if (webModel.webView && idx < self.webModelArray.count - 1) {
                toDeleteWebModel = webModel;
                *stop = YES;
            }
        }];
        
        toDeleteWebModel.webView = nil;
    });
}

- (void)cleanDisk{
    [self cleanDiskWithCompletionBlock:nil];
}

- (void)backgroundCleanDisk{
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self cleanDiskWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)cleanDiskWithCompletionBlock:(WebBrowserNoParamsBlock)completionBlock{
    //save browse data
    [self saveWebModelData];
    
    dispatch_async(self.synchQueue, ^{
        //remove outdated image
        NSMutableSet *urlSet = [NSMutableSet setWithCapacity:self.webModelArray.count];
        [self.webModelArray enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
            [urlSet addObject:[[self defaultCachePathForKey:webModel.imageKey] lastPathComponent]];
        }];
        
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.imagesFolderPath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey];
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL includingPropertiesForKeys:resourceKeys options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
        
        NSMutableArray *urlsToDelete = [NSMutableArray array];
        foreach(fileURL, fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
            if (![urlSet containsObject:[fileURL lastPathComponent]]) {
                [urlsToDelete addObject:fileURL];
            }
        }
        
        foreach(fileURL, urlsToDelete) {
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        }
        
        if (completionBlock) {
            dispatch_main_safe_async(^{
                completionBlock();
            })
        }
    });
}

- (void)noImageModeChanged{
    JSBlock block = ^(BrowserWebView *webView){
        [ExtentionsManager evaluateScriptButNotLoadExtentionsWithWebView:webView jsKey:KeyNoImageModeStatus];
    };
    [self enumerateWebViewsToEvaluateJSWithBlock:block];
}

- (void)eyeProtectiveModeChanged{
    JSBlock block = ^(BrowserWebView *webView){
        [ExtentionsManager evaluateScriptButNotLoadExtentionsWithWebView:webView jsKey:KeyEyeProtectiveStatus];
    };
    [self enumerateWebViewsToEvaluateJSWithBlock:block];
}

- (void)enumerateWebViewsToEvaluateJSWithBlock:(JSBlock)block{
    NSCParameterAssert(block);
    
    [[self.webModelArray copy] enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
        if (webModel.webView) {
            dispatch_main_safe_async(^{
                block(webModel.webView);
            })
        }
    }];
    [[self.webModelArray lastObject].webView reload];
}

#pragma mark - BrowserWebViewDelegate Method

//当解析完head标签后注入无图模式js,需要注意的是，当启用无图模式时，UIWebView依然会进行图片网络请求,只是设置visible为false
- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString*)titleName{
    [ExtentionsManager loadExtentionsIfNeededWhenGotTitleWithWebView:webView];
    [[HistorySQLiteManager sharedInstance] insertOrUpdateHistoryWithURL:webView.mainFURL title:titleName];
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    if (error.code == kCFURLErrorCancelled) {
        return;
    }
    
    NSURL *url = error.userInfo[NSURLErrorFailingURLErrorKey];
    
    if (error.code == kCFURLErrorServerCertificateUntrusted && [url.absoluteString isEqualToString:webView.mainFURL]) {
        [self handleSSLUntrustedWithWebView:webView];
    }
    
    //just trigger error page in case of "http" or "https"
    if ([url.absoluteString isEqualToString:webView.mainFURL] && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
        [ErrorPageHelper showPageWithError:error URL:url inWebView:webView];
        [self saveWebModelData];
    }
}

- (void)webViewForMainFrameDidFinishLoad:(BrowserWebView *)webView{
    [self saveWebModelData];
}

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    [ExtentionsManager loadExtentionsIfNeededWhenWebViewDidFinishLoad:webView];
}

// Add basic authentication
- (void)webView:(BrowserWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (challenge.previousFailureCount == 0 && ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] || [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest] || [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodNTLM])) {
        NSURLCredential *credential = challenge.proposedCredential;
        if (credential && credential.user.length > 0) {
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        } else if (challenge.protectionSpace.host.length > 0) {
            UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"网页认证" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"登陆" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSString *user = actionSheetController.textFields[0].text;
                NSString *pass = actionSheetController.textFields[1].text;
                
                if (user.length > 0 && pass.length > 0) {
                    NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:user password:pass persistence:NSURLCredentialPersistenceForSession];
                    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
                }
                
            }];
            [actionSheetController addAction:loginAction];
            
            UIAlertAction *cancelAction = [UIAlertAction actionDismiss];
            [actionSheetController addAction:cancelAction];
            
            [actionSheetController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"用户名";
            }];
            
            [actionSheetController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"密码";
                textField.secureTextEntry = YES;
            }];
            
            if (!BrowserVC.presentedViewController) {
                [BrowserVC presentViewController:actionSheetController animated:YES completion:nil];
            }
        }
    }
    else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

#pragma mark - SSL Error Handler

- (void)handleSSLUntrustedWithWebView:(BrowserWebView *)webView{
    UIAlertController *accessDenied = [UIAlertController alertControllerWithTitle:@"您的连接不是私密连接" message:[NSString stringWithFormat:@"攻击者可能会试图从 %@ 窃取您的信息（例如：密码、通讯内容或信用卡信息）。",webView.request.URL.host] preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *dismissAction = [UIAlertAction actionDismiss];
    [accessDenied addAction:dismissAction];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"继续前往（不安全）" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        URLConnectionDelegateProxy *proxy __attribute__((unused)) = [[URLConnectionDelegateProxy alloc] initWithURL:webView.request.URL success:^{
            [webView reload];
        } failure:nil];
    }];
    [accessDenied addAction:continueAction];
    
    [BrowserVC presentViewController:accessDenied animated:YES completion:nil];
    
}

#pragma mark - Dealloc

- (void)dealloc{
    [Notifier removeObserver:self];
}

@end
