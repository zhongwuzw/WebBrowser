//
//  TabManager.h
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;

@end

@class BrowserWebView;

@interface TabManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<BrowserWebView *> *browserViewArray;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(TabManager)
- (NSArray<WebModel *> *)getWebViewSnapshot;

@end
