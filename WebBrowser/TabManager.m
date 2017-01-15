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

#define MULTI_WINDOW_FILE_NAME    @"multiWindowHis.plist"

#define KEY_WEB_TITLE   @"KEY_WEB_TITLE"
#define KEY_WEB_URL     @"KEY_WEB_URL"
#define KEY_WEB_IMAGE   @"KEY_WEB_IMAGE"

@implementation WebModel

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectOfClass:[NSString class] forKey:KEY_WEB_TITLE];
        _url = [aDecoder decodeObjectOfClass:[NSString class] forKey:KEY_WEB_URL];
        _image = [aDecoder decodeObjectOfClass:[UIImage class] forKey:KEY_WEB_IMAGE];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:KEY_WEB_TITLE];
    [aCoder encodeObject:self.url forKey:KEY_WEB_URL];
    [aCoder encodeObject:self.image forKey:KEY_WEB_IMAGE];
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

@end

@interface TabManager ()

@property (nonatomic, strong) NSMutableArray<BrowserWebView *> *browserViewArray;
@property (nonatomic, copy)   NSString *filePath;
@property (nonatomic, strong) dispatch_queue_t synchQueue;

@end

@implementation TabManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TabManager)

- (instancetype)init{
    if (self = [super init]) {
        _filePath = [DocumentPath stringByAppendingPathComponent:MULTI_WINDOW_FILE_NAME];
    }
    
    return self;
}

- (NSMutableArray<BrowserWebView *> *)browserViewArray{
    if (!_browserViewArray) {
        _browserViewArray = [NSMutableArray arrayWithCapacity:11];
        BrowserWebView *webView = [BrowserWebView new];
        webView.scrollView.delegate = [BrowserViewController sharedInstance];
        //        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://m.baidu.com"]];
        
        [_browserViewArray addObject:webView];
    }
    return _browserViewArray;
}

- (NSArray<WebModel *> *)getWebViewSnapshot{
    UIImage *image = [self.browserViewArray[0] snapshotForBrowserWebView];
    WebModel *webModel = [WebModel new];
    webModel.title = @"百度一下";
    webModel.image = image;
    
    NSArray<WebModel *> *webArray = [NSArray arrayWithObjects:webModel, webModel,webModel, webModel, webModel,webModel, webModel, webModel,webModel, nil];
    
    return webArray;
}

@end
