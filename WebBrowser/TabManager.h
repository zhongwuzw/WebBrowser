//
//  TabManager.h
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrowserContainerView.h"

@class WebModel, SessionData;

typedef void(^MultiWebViewOperationBlock)(NSArray<WebModel *> *);
typedef void(^CurWebViewOperationBlock)(WebModel *, BrowserWebView *);
typedef void(^WebBrowserNoParamsBlock)(void);
typedef void(^SwitchOperationBlock)(WebModel *preWebModel, WebModel *curWebModel);

@interface WebModel : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *imageKey;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) BrowserWebView *webView;
@property (nonatomic, assign) BOOL isImageProcessed;
@property (nonatomic, strong) SessionData *sessionData;

@end

@class BrowserWebView;

@interface TabManager : NSObject

@property (nonatomic, weak) BrowserContainerView *browserContainerView;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(TabManager)
- (void)setMultiWebViewOperationBlockWith:(MultiWebViewOperationBlock)block;
- (void)setCurWebViewOperationBlockWith:(CurWebViewOperationBlock)block;
- (void)switchToLeftWindowWithCompletion:(SwitchOperationBlock)block;
- (void)switchToRightWindowWithCompletion:(SwitchOperationBlock)block;
- (void)updateWebModelArray:(NSArray<WebModel *> *)webArray;
- (void)updateWebModelArray:(NSArray<WebModel *> *)webArray completion:(WebBrowserNoParamsBlock)block;
- (void)addWebModelWithURL:(NSURL *)url completion:(WebBrowserNoParamsBlock)completion;
- (void)saveWebModelData;
- (WebModel *)getCurrentWebModel;
- (BOOL)isCurrentWebView:(BrowserWebView *)webView;
- (void)stopLoadingCurrentWebView;
- (NSUInteger)numberOfTabs;

@end
