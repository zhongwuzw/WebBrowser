//
//  TabManager.h
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebModel;

typedef void(^MultiWebViewOperationBlock)(NSArray<WebModel *> *);
typedef void(^CurWebViewOperationBlock)(WebModel *, BrowserWebView *);

@interface WebModel : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imageURL;

@end

@class BrowserWebView;

@interface TabManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(TabManager)
- (NSArray<WebModel *> *)getWebViewSnapshot;
- (void)setMultiWebViewOperationBlockWith:(MultiWebViewOperationBlock)block;
- (void)setCurWebViewOperationBlockWith:(CurWebViewOperationBlock)block;

@end
