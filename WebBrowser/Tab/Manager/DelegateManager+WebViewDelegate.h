//
//  DelegateManager+WebViewDelegate.h
//  WebBrowser
//
//  Created by 钟武 on 2017/1/31.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "DelegateManager.h"

@protocol WebViewDelegate;
@class WeakWebBrowserDelegate;

@interface WeakWebBrowserDelegate : NSObject

@property (nonatomic, weak) id<WebViewDelegate> delegate;

@end

@interface DelegateManager (WebViewDelegate)

- (NSArray<WeakWebBrowserDelegate *> *)webViewDelegates;
- (void)addWebViewDelegate:(id<WebViewDelegate>)delegate;

@end
