//
//  BrowserViewController.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserViewController.h"
#import "BrowserContainerView.h"
#import "BrowserTopToolBar.h"
#import "BrowserHeader.h"

@interface BrowserViewController () <WebViewDelegate>

@property (nonatomic, strong) BrowserContainerView *browserContainerView;
@property (nonatomic, strong) UIToolbar *bottomToolBar;
@property (nonatomic, strong) BrowserTopToolBar *browserTopToolBar;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) BOOL isWebViewDecelerate;
@property (nonatomic, assign) ScrollDirection webViewScrollDirection;

@end

@implementation BrowserViewController

SYNTHESIZE_SINGLETON_FOR_CLASS(BrowserViewController)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeView];

    self.lastContentOffset = - TOP_TOOL_BAR_HEIGHT;
}

- (void)initializeView{
    self.view.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    self.browserContainerView = ({
        BrowserContainerView *browserContainerView = [BrowserContainerView new];
        [self.view addSubview:browserContainerView];
        
        browserContainerView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
        browserContainerView.webViewDelegate = self;
        
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
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - BOTTOM_TOOL_BAR_HEIGHT, self.view.width, BOTTOM_TOOL_BAR_HEIGHT)];
        [self.view addSubview:toolBar];
        
        UIBarButtonItem *backItem = [self createBottomToolBarButtonWithImage:@"toolbar_goback_normal" tag:BottomToolBarBackButtonTag];
        
        UIBarButtonItem *forwardItem = [self createBottomToolBarButtonWithImage:@"toolbar_goforward_normal" tag:BottomToolBarForwardButtonTag];
        
        UIBarButtonItem *refreshItem = [self createBottomToolBarButtonWithImage:@"menu_refresh_normal" tag:BottomToolBarRefreshButtonTag];

        UIBarButtonItem *settingItem = [self createBottomToolBarButtonWithImage:@"toolbar_more_normal" tag:BottomToolBarMoreButtonTag];
        
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [toolBar setItems:@[backItem,flexibleItem,forwardItem,flexibleItem,refreshItem,flexibleItem,settingItem] animated:YES];
        
        toolBar;
    });
}

- (UIBarButtonItem *)createBottomToolBarButtonWithImage:(NSString *)imageName tag:(NSInteger)tag{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(handleBottomToolBarButtonClicked:)];
    item.tag = tag;
    
    return item;
}

#pragma mark - Bottom ToolBar Button Clicked

- (void)handleBottomToolBarButtonClicked:(UIBarButtonItem *)item{
    NSLog(@"%ld",(long)item.tag);
}

- (void)backButtonClicked:(id)sender{
    NSArray <UIBarButtonItem *>*items =  self.bottomToolBar.items;
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menu_refresh_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonClicked:)];
    
    NSRange theRange;
    
    theRange.location = 1;
    theRange.length = _bottomToolBar.items.count - 1;
    
    NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:_bottomToolBar.items.count];
    [finalArray addObject:refreshItem];
    [finalArray addObjectsFromArray:[items subarrayWithRange:theRange]];
    
    [self.bottomToolBar setItems:finalArray animated:NO];
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset = scrollView.contentOffset.y - self.lastContentOffset;
    
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        if (_isWebViewDecelerate || (scrollView.contentOffset.y >= -TOP_TOOL_BAR_HEIGHT && scrollView.contentOffset.y <= 0)) {
            [self handleTopToolBarWithOffset:yOffset];
        }
        self.webViewScrollDirection = ScrollDirectionDown;
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y >= - TOP_TOOL_BAR_HEIGHT)
    {
        [self handleTopToolBarWithOffset:yOffset];
        self.webViewScrollDirection = ScrollDirectionUp;
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.webViewScrollDirection == ScrollDirectionDown) {
        self.isWebViewDecelerate = decelerate;
    }
    else
        self.isWebViewDecelerate = NO;
}

#pragma mark - Handle TopToolBar Scroll

- (void)handleTopToolBarWithOffset:(CGFloat)offset{
    CGRect bottomRect = self.bottomToolBar.frame;
    //缩小toolbar
    if (offset > 0) {
        if (self.browserTopToolBar.height - offset <= TOP_TOOL_BAR_THRESHOLD) {
            self.browserTopToolBar.height = TOP_TOOL_BAR_THRESHOLD;
            
            bottomRect.origin.y = self.view.height;
        }
        else
        {
            self.browserTopToolBar.height -= offset;
            bottomRect.origin.y += BOTTOM_TOOL_BAR_HEIGHT * offset / (TOP_TOOL_BAR_HEIGHT - TOP_TOOL_BAR_THRESHOLD);
        }
    }
    else{
        if (self.browserTopToolBar.height + (-offset) >= TOP_TOOL_BAR_HEIGHT) {
            self.browserTopToolBar.height = TOP_TOOL_BAR_HEIGHT;
            bottomRect.origin.y = self.view.height - BOTTOM_TOOL_BAR_HEIGHT;
        }
        else
        {
            self.browserTopToolBar.height += (-offset);
            bottomRect.origin.y -= BOTTOM_TOOL_BAR_HEIGHT * offset / (TOP_TOOL_BAR_HEIGHT - TOP_TOOL_BAR_THRESHOLD);
        }
    }
    
    self.bottomToolBar.frame = bottomRect;
}

#pragma mark - WebViewDelegate
- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    [self.browserTopToolBar setTopURLOrTitle:[webView mainFTitle]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
