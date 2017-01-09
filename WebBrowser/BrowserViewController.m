//
//  BrowserViewController.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "BrowserViewController.h"
#import "BrowserContainerView.h"
#import "BrowserTopToolBar.h"
#import "BrowserHeader.h"
#import "BrowserBottomToolBar.h"
#import "CardMainView.h"
#import "SettingsViewController.h"

@interface BrowserViewController () <WebViewDelegate, BrowserBottomToolBarButtonClickedDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) BrowserContainerView *browserContainerView;
@property (nonatomic, strong) BrowserBottomToolBar *bottomToolBar;
@property (nonatomic, strong) BrowserTopToolBar *browserTopToolBar;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) BOOL isWebViewDecelerate;
@property (nonatomic, assign) ScrollDirection webViewScrollDirection;
@property (nonatomic, weak) id<BrowserBottomToolBarButtonClickedDelegate> browserButtonDelegate;
@property (nonatomic, strong) CardMainView *cardMainView;

@end

@implementation BrowserViewController

SYNTHESIZE_SINGLETON_FOR_CLASS(BrowserViewController)

- (CardMainView *)cardMainView{
    if (!_cardMainView) {
        _cardMainView = [[CardMainView alloc] initWithFrame:self.view.bounds];
    }
    return _cardMainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeView];
    
    [self initializeNotification];

    self.lastContentOffset = - TOP_TOOL_BAR_HEIGHT;
    
    [[DelegateManager sharedInstance] registerDelegate:self forKey:DelegateManagerWebView];
}

- (void)initializeView{
    self.view.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    self.browserContainerView = ({
        BrowserContainerView *browserContainerView = [BrowserContainerView new];
        [self.view addSubview:browserContainerView];
        
        browserContainerView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
        browserContainerView.webViewDelegate = self;
        self.browserButtonDelegate = browserContainerView;
        
        browserContainerView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_HEIGHT, 0, 0, 0);
        
        browserContainerView;
    });
    
    self.browserTopToolBar = ({
        BrowserTopToolBar *browserTopToolBar = [[BrowserTopToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TOP_TOOL_BAR_HEIGHT)];
        [self.view addSubview:browserTopToolBar];
        
        browserTopToolBar.backgroundColor = UIColorFromRGB(0xF8F8F8);
        
        browserTopToolBar;
    });
    
    self.bottomToolBar = ({
        BrowserBottomToolBar *toolBar = [[BrowserBottomToolBar alloc] initWithFrame:CGRectMake(0, self.view.height - BOTTOM_TOOL_BAR_HEIGHT, self.view.width, BOTTOM_TOOL_BAR_HEIGHT)];
        [self.view addSubview:toolBar];
        
        toolBar.browserButtonDelegate = self;
    
        toolBar;
    });
}

#pragma mark - Notification

- (void)initializeNotification{
    [Notifier addObserver:self selector:@selector(receiveOpenAppstore:) name:kModalAppstoreOpen object:nil];
}

- (void)receiveOpenAppstore:(NSNotification*)notification
{
    NSString* appstoreId = notification.object;
    
    if ([appstoreId isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [NSNumberFormatter new];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *number = [f numberFromString:appstoreId];
        [self openAppstoreWithURL:number];
    }
}

- (void)openAppstoreWithURL:(NSNumber *)appstoreID{
    if (!appstoreID) {
        return;
    }
    
    SKStoreProductViewController *storeViewController = [SKStoreProductViewController new];
    storeViewController.delegate = self;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [dict setObject:appstoreID forKey:SKStoreProductParameterITunesItemIdentifier];
    
    [storeViewController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error){
        if (result) {
            [self.navigationController presentViewController:storeViewController animated:YES completion:nil];
        }
    }];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController
{
    if (viewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //点击新链接或返回时，scrollView会调用该方法
    if (!(!scrollView.decelerating && !scrollView.dragging && !scrollView.tracking)) {
        CGFloat yOffset = scrollView.contentOffset.y - self.lastContentOffset;
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            if (_isWebViewDecelerate || (scrollView.contentOffset.y >= -TOP_TOOL_BAR_HEIGHT && scrollView.contentOffset.y <= 0)) {
                //浮点数不能做精确匹配，不过此处用等于满足我的需求
                if (!(self.browserTopToolBar.height == TOP_TOOL_BAR_HEIGHT)) {
                    [self recoverToolBar];
                }
            }
            self.webViewScrollDirection = ScrollDirectionDown;
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y >= - TOP_TOOL_BAR_HEIGHT)
        {
            if (!(scrollView.contentOffset.y < 0 && scrollView.decelerating)) {
                [self handleToolBarWithOffset:yOffset];
            }
            self.webViewScrollDirection = ScrollDirectionUp;
        }
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
    
}

- (void)recoverToolBar{
    [UIView animateWithDuration:.2 animations:^{
        self.browserTopToolBar.height = TOP_TOOL_BAR_HEIGHT;
        CGRect bottomRect = self.bottomToolBar.frame;
        bottomRect.origin.y = self.view.height - BOTTOM_TOOL_BAR_HEIGHT;
        self.bottomToolBar.frame = bottomRect;
        self.browserContainerView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_HEIGHT, 0, 0, 0);
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.webViewScrollDirection == ScrollDirectionDown) {
        self.isWebViewDecelerate = decelerate;
    }
    else
        self.isWebViewDecelerate = NO;
}

#pragma mark - Handle TopToolBar Scroll

- (void)handleToolBarWithOffset:(CGFloat)offset{
    CGRect bottomRect = self.bottomToolBar.frame;
    //缩小toolbar
    if (offset > 0) {
        if (self.browserTopToolBar.height - offset <= TOP_TOOL_BAR_THRESHOLD) {
            self.browserTopToolBar.height = TOP_TOOL_BAR_THRESHOLD;
            self.browserContainerView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_THRESHOLD, 0, 0, 0);

            bottomRect.origin.y = self.view.height;
        }
        else
        {
            self.browserTopToolBar.height -= offset;
            bottomRect.origin.y += BOTTOM_TOOL_BAR_HEIGHT * offset / (TOP_TOOL_BAR_HEIGHT - TOP_TOOL_BAR_THRESHOLD);
            UIEdgeInsets insets = self.browserContainerView.scrollView.contentInset;
            insets.top -= offset;
            self.browserContainerView.scrollView.contentInset = insets;
        }
    }
    else{
        if (self.browserTopToolBar.height + (-offset) >= TOP_TOOL_BAR_HEIGHT) {
            self.browserTopToolBar.height = TOP_TOOL_BAR_HEIGHT;
            bottomRect.origin.y = self.view.height - BOTTOM_TOOL_BAR_HEIGHT;
            self.browserContainerView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_HEIGHT, 0, 0, 0);
        }
        else
        {
            self.browserTopToolBar.height += (-offset);
            bottomRect.origin.y -= BOTTOM_TOOL_BAR_HEIGHT * (-offset) / (TOP_TOOL_BAR_HEIGHT - TOP_TOOL_BAR_THRESHOLD);
            UIEdgeInsets insets = self.browserContainerView.scrollView.contentInset;
            insets.top += (-offset);
            self.browserContainerView.scrollView.contentInset = insets;
        }
    }
    
    self.bottomToolBar.frame = bottomRect;
}

#pragma mark - WebViewDelegate

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //点击链接或加载页面等情况下重新恢复界面
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeOther) {
        [self recoverToolBar];
    }
    if ([self.browserTopToolBar respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.browserTopToolBar webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

#pragma mark - BrowserBottomToolBarButtonClickedDelegate

- (void)browserBottomToolBarButtonClickedWithTag:(BottomToolBarButtonTag)tag{
    if ([self.browserButtonDelegate respondsToSelector:@selector(browserBottomToolBarButtonClickedWithTag:)]) {
        [self.browserButtonDelegate browserBottomToolBarButtonClickedWithTag:tag];
    }
    if (tag == BottomToolBarMoreButtonTag) {
        NSArray<SettingsMenuItem *> *items =
        @[
          [SettingsMenuItem itemWithText:@"书签" image:[UIImage imageNamed:@"album"] action:nil],
          [SettingsMenuItem itemWithText:@"历史" image:[UIImage imageNamed:@"album"] action:nil],
          [SettingsMenuItem itemWithText:@"设置" image:[UIImage imageNamed:@"album"] action:nil],
          [SettingsMenuItem itemWithText:@"多窗口" image:[UIImage imageNamed:@"album"] action:^{
              [self.view addSubview:self.cardMainView];
          }],
          [SettingsMenuItem itemWithText:@"分享" image:[UIImage imageNamed:@"album"] action:nil]
          ];
        
        [SettingsViewController presentFromViewController:self withItems:items completion:nil];
    }
}

#pragma mark - Memory Warning Method

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
