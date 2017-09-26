//
//  BaseTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/8.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BaseTableViewController.h"

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
