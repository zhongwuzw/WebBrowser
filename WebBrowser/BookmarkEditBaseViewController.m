//
//  BookmarkEditBaseViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkEditBaseViewController.h"
#import "BookmarkDataManager.h"
#import "BookmarkEditTextFieldTableViewCell.h"

NSString *const kBookmarkEditTextFieldCellIdentifier = @"kBookmarkEditTextFieldCellIdentifier";

@interface BookmarkEditBaseViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BookmarkEditBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(handleDoneItemClicked)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navigationBar.frame), self.view.width, self.view.height - CGRectGetMaxY(navigationBar.frame)) style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookmarkEditTextFieldTableViewCell class]) bundle:nil] forCellReuseIdentifier:kBookmarkEditTextFieldCellIdentifier];
    
    _tableView.tableFooterView = [UIView new];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)initData{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView reloadData];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Handle NavigationItem Clicked

- (void)handleDoneItemClicked{}

- (void)exit{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - Dealloc

- (void)dealloc{
    DDLogDebug(@"%@ dealloced",NSStringFromClass([self class]));
}

@end
