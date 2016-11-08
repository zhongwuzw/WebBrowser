//
//  BrwoserContentView.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/9.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserWebView.h"
#import "BrowserBottomToolBarHeader.h"

@interface BrowserContainerView : UIView <BrowserBottomToolBarButtonClickedDelegate>

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id<WebViewDelegate> webViewDelegate;

@end
