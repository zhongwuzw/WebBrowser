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
#import "JavaScriptHelper.h"
#import "PreferenceHelper.h"
#import "ErrorPageHelper.h"
#import "BrowserContainerView.h"
#import "SessionData.h"
#import "WebViewBackForwardList.h"

#import <CommonCrypto/CommonDigest.h>

static NSString *const MULTI_WINDOW_FILE_NAME    = @"multiWindowHis.plist";
static NSString *const MY_HISTORY_DATA_KEY       = @"multiWindowHisData";
static NSString *const MULTI_WINDOW_IMAGE_FOLDER = @"multiWindowImages";

static NSString *const KEY_WEB_TITLE        = @"KEY_WEB_TITLE";
static NSString *const KEY_WEB_URL          = @"KEY_WEB_URL";
static NSString *const KEY_WEB_IMAGE        = @"KEY_WEB_IMAGE";
static NSString *const KEY_WEB_IMAGE_URL    = @"KEY_WEB_IMAGE_URL";
static NSString *const KEY_WEB_SESSION_DATA    = @"KEY_WEB_SESSION_DATA";

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

- (void)dealloc{
    self.webView.webModel = nil;
    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];
    self.webView = nil;
}

@end

@interface TabManager ()

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
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
                NSData *data = [NSData dataWithContentsOfFile:_filePath options:NSDataReadingUncached error:nil];
                if (data) {
                    NSKeyedUnarchiver *unarchiver;
                    @try {
                        unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                        NSArray<WebModel *> *array = [unarchiver decodeObjectForKey:MY_HISTORY_DATA_KEY];
                        
                        if (array && [array isKindOfClass:[NSArray<WebModel *> class]] && array.count > 0) {
                            [_webModelArray addObjectsFromArray:array];
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
    });
}

- (void)saveWebModelToDisk{
    [_webModelArray enumerateObjectsUsingBlock:^(WebModel *model, NSUInteger idx, BOOL *stop){
        if (model.webView) {
            WebViewBackForwardList *backForwardList = [model.webView webViewBackForwardList];
            NSArray *urls = [self getBackForwardListURL:backForwardList];
            NSInteger currentPage = -backForwardList.forwardList.count;
            model.sessionData = [[SessionData alloc] initWithCurrentPage:currentPage urls:urls];
        }
    }];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_webModelArray forKey:MY_HISTORY_DATA_KEY];
    [archiver finishEncoding];
    
    [data writeToFile:_filePath atomically:YES];
}

//save webModel, public API
- (void)saveWebModelData{
    dispatch_async(self.synchQueue, ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self saveWebModelToDisk];
            
            [_webModelArray enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
                @autoreleasepool {
                    if (webModel.webView) {
                        NSString *key = [NSString stringWithFormat:@"%f%@%@",[[NSDate date] timeIntervalSince1970],webModel.url,webModel.title];
                        [self storeImage:webModel.image forKey:key];
                        webModel.imageKey = key;
                    }
                }
            }];
        });
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

- (void)setMultiWebViewOperationBlockWith:(MultiWebViewOperationBlock)block{
    dispatch_async(self.synchQueue, ^{
        [_webModelArray enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
            webModel.isImageProcessed = NO;
            UIImage *image = [webModel.webView snapshotForBrowserWebView];
            if (!image) {
                image = [self imageFromDiskCacheForKey:webModel.imageKey];
                if (image) {
                    webModel.isImageProcessed = YES;
                }
            }
            if (!image) {
                image = [UIImage imageNamed:DEFAULT_CARD_CELL_IMAGE];
            }
            webModel.image = image;
        }];
        dispatch_main_sync_safe(^{
            if (block) {
                block([_webModelArray copy]);
            }
        })
    });
}

- (void)setCurWebViewOperationBlockWith:(CurWebViewOperationBlock)block{
    dispatch_async(self.synchQueue, ^{
        dispatch_main_sync_safe(^{
            BrowserWebView *browserWebView;
            WebModel *curModel = [_webModelArray lastObject];
            if (!curModel.webView) {
                browserWebView = [BrowserWebView new];
                browserWebView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_HEIGHT, 0, BOTTOM_TOOL_BAR_HEIGHT, 0);
                _webModelArray[_webModelArray.count - 1].webView = browserWebView;
                browserWebView.webModel = curModel;
            }
            else
                browserWebView = curModel.webView;
            
            browserWebView.scrollView.delegate = [BrowserViewController sharedInstance];
            if (block) {
                block([_webModelArray lastObject], browserWebView);
            }
        })
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
            dispatch_main_async_safe(^{
                block();
            })
        }
    });
}

#pragma mark - Disk Image Method

- (void)storeImage:(UIImage *)image forKey:(NSString *)key{
    if (!image || !key) {
        return;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
    
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
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            //remove outdated image
            NSMutableSet *urlSet = [NSMutableSet setWithCapacity:self.webModelArray.count];
            [self.webModelArray enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
                [urlSet addObject:[[self defaultCachePathForKey:webModel.imageKey] lastPathComponent]];
            }];
            
            NSURL *diskCacheURL = [NSURL fileURLWithPath:self.imagesFolderPath isDirectory:YES];
            NSArray *resourceKeys = @[NSURLIsDirectoryKey];
            
            NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL includingPropertiesForKeys:resourceKeys options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
            
            NSMutableArray *urlsToDelete = [NSMutableArray array];
            for (NSURL *fileURL in fileEnumerator) {
                NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
                
                if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                    continue;
                }
                
                if (![urlSet containsObject:[fileURL lastPathComponent]]) {
                    [urlsToDelete addObject:fileURL];
                }
            }
            
            for (NSURL *fileURL in urlsToDelete) {
                [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
            }
            
            if (completionBlock) {
                dispatch_main_async_safe(^{
                    completionBlock();
                })
            }
        });
    });
}

- (void)noImageModeChanged{
    [[self.webModelArray copy] enumerateObjectsUsingBlock:^(WebModel *webModel, NSUInteger idx, BOOL *stop){
        if (webModel.webView) {
            dispatch_main_async_safe(^{
                [JavaScriptHelper setNoImageMode:[PreferenceHelper boolForKey:KeyNoImageModeStatus] webView:webModel.webView loadPrimaryScript:NO];
            })
        }
    }];
    [[self.webModelArray lastObject].webView reload];
}

#pragma mark - WebViewDelegate Method

//当解析完head标签后注入无图模式js,需要注意的是，当启用无图模式时，UIWebView依然会进行图片网络请求
- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString*)titleName{
    [JavaScriptHelper setNoImageMode:[PreferenceHelper boolForKey:KeyNoImageModeStatus] webView:webView loadPrimaryScript:YES];
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) {
        return;
    }
    
    if (error.code == kCFURLErrorCancelled) {
        return;
    }
    
    NSURL *url = error.userInfo[NSURLErrorFailingURLErrorKey];
    //just trigger error page in case of "http" or "https"
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        [ErrorPageHelper showPageWithError:error URL:url inWebView:webView];
        [self saveWebModelData];
    }
}

- (void)webViewForMainFrameDidFinishLoad:(BrowserWebView *)webView{
    [self saveWebModelData];
}

#pragma mark - Dealloc

- (void)dealloc{
    [Notifier removeObserver:self];
}

@end
