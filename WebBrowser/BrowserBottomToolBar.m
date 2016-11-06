//
//  BrowserBottomToolBar.m
//  WebBrowser
//
//  Created by 钟武 on 2016/11/6.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserBottomToolBar.h"
#import "BrowserBottomToolBarHeader.h"

@interface BrowserBottomToolBar () 

@property (nonatomic, weak) UIBarButtonItem *refreshOrStopItem;

@end

@implementation BrowserBottomToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    
    return self;
}

- (void)initializeView{
    UIBarButtonItem *backItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_BACK_STRING tag:BottomToolBarBackButtonTag];
    
    UIBarButtonItem *forwardItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_FORWARD_STRING tag:BottomToolBarForwardButtonTag];
    
    UIBarButtonItem *refreshOrStopItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_STOP_STRING tag:BottomToolBarRefreshOrStopButtonTag];
    refreshOrStopItem.width = 30;
    self.refreshOrStopItem = refreshOrStopItem;
    
    UIBarButtonItem *settingItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_MORE_STRING tag:BottomToolBarMoreButtonTag];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexibleItem.tag = BottomToolBarFlexibleButtonTag;
    
    [self setItems:@[backItem,flexibleItem,forwardItem,flexibleItem,refreshOrStopItem,flexibleItem,settingItem] animated:YES];
    
}

- (UIBarButtonItem *)createBottomToolBarButtonWithImage:(NSString *)imageName tag:(NSInteger)tag{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(handleBottomToolBarButtonClicked:)];
    item.tag = tag;
    
    return item;
}

- (void)handleBottomToolBarButtonClicked:(UIBarButtonItem *)item{
    
}

- (void)backButtonClicked:(id)sender{
    
}

- (void)setToolBarButtonRefreshOrStop:(BOOL)isRefresh{
    NSString *imageName = isRefresh ? TOOLBAR_BUTTON_REFRESH_STRING : TOOLBAR_BUTTON_STOP_STRING;
    
    self.refreshOrStopItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - WebViewDelegate

- (void)webViewDidStartLoad:(BrowserWebView *)webView{
    
}

- (void)webViewMainFrameDidFinishLoad:(BrowserWebView *)webView{
    [self setToolBarButtonRefreshOrStop:true];
}

- (void)webViewMainFrameDidCommitLoad:(BrowserWebView *)webView{
    [self setToolBarButtonRefreshOrStop:false];
}

@end
