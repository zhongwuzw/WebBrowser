//
//  DelegateManager+WebViewDelegate.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/31.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "DelegateManager+WebViewDelegate.h"
#import "BrowserWebView.h"

#import <objc/runtime.h>

static char delegatesKey;

@implementation WeakWebBrowserDelegate

- (instancetype)initWithDelegate:(id<WebViewDelegate>)delegate{
    if (self = [self init]) {
        _delegate = delegate;
    }
    
    return self;
}

@end

@interface DelegateManager ()

@property (nonatomic, strong) NSMutableArray<WeakWebBrowserDelegate *> *delegates;

@end

@implementation DelegateManager (WebViewDelegate)

- (NSMutableArray<WeakWebBrowserDelegate *> *)delegates{
    NSMutableArray *delegates = objc_getAssociatedObject(self, &delegatesKey);
    if (delegates) {
        return delegates;
    }
    
    delegates = [NSMutableArray array];
    objc_setAssociatedObject(self, &delegatesKey, delegates, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return delegates;
}

- (void)addWebViewDelegate:(id<WebViewDelegate>)delegate{
    foreach(weakDelegate, self.delegates) {
        if (!weakDelegate.delegate) {
            weakDelegate.delegate = delegate;
            return;
        }
    }
    
    [self.delegates addObject:[[WeakWebBrowserDelegate alloc] initWithDelegate:delegate]];
}

- (NSArray<WeakWebBrowserDelegate *> *)webViewDelegates{
    return [NSArray arrayWithArray:self.delegates];
}

@end
