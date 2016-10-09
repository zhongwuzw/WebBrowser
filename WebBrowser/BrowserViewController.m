//
//  BrowserViewController.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserViewController.h"
#import "BrowserContainerView.h"

@interface BrowserViewController ()

@property (nonatomic, strong) BrowserContainerView *browserContainerView;
@property (nonatomic, strong) UIToolbar *bottomToolBar;

@end

@implementation BrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeView];

}

- (void)initializeView{
    self.browserContainerView = [[BrowserContainerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_browserContainerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
