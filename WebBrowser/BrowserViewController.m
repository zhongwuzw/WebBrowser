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

#define BOTTOM_TOOL_BAR_HEIGHT 44
#define TOP_TOOL_BAR_HEIGHT 50

@interface BrowserViewController ()

@property (nonatomic, strong) BrowserContainerView *browserContainerView;
@property (nonatomic, strong) UIToolbar *bottomToolBar;
@property (nonatomic, strong) BrowserTopToolBar *browserTopToolBar;

@end

@implementation BrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeView];

}

- (void)initializeView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    self.bottomToolBar = ({
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - BOTTOM_TOOL_BAR_HEIGHT, self.view.width, BOTTOM_TOOL_BAR_HEIGHT)];
        [self.view addSubview:toolBar];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"toolbar_goback_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
        
        UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menu_refresh_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonClicked:)];
        
        UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"toolbar_more_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonClicked:)];
        
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [toolBar setItems:@[backItem,flexibleItem,refreshItem,flexibleItem,settingItem] animated:YES];
        
        toolBar;
    });
    
    self.browserTopToolBar = ({
        BrowserTopToolBar *browserTopToolBar = [[BrowserTopToolBar alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, self.view.width, TOP_TOOL_BAR_HEIGHT)];
        [self.view addSubview:browserTopToolBar];
        
        
        
        browserTopToolBar;
    });
    
    self.browserContainerView = ({
        BrowserContainerView *browserContainerView = [BrowserContainerView new];
        [self.view addSubview:browserContainerView];
        
        [browserContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[browserContainerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(browserContainerView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_browserTopToolBar]-0-[browserContainerView]-0-[_bottomToolBar]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_browserTopToolBar,browserContainerView,_bottomToolBar)]];
        
        browserContainerView;
    });
}

- (void)settingButtonClicked:(id)sender{

    
}

- (void)refreshButtonClicked:(id)sender{
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
