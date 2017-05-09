//
//  BookmarkEditViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkEditViewController.h"
#import "BookmarkDataManager.h"
#import "BookmarkEditTextFieldTableViewCell.h"

static NSString *const kBookmarkEditTextFieldCellIdentifier = @"kBookmarkEditTextFieldCellIdentifier";

@interface BookmarkEditViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) BookmarkDataManager *dataManager;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) BookmarkEditCompletion completion;

@end

@implementation BookmarkEditViewController

- (instancetype)initWithDataManager:(BookmarkDataManager *)dataManager completion:(BookmarkEditCompletion)completion{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _dataManager = dataManager;
        _completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
}

- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(handleDoneItemClicked)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navigationBar.frame), self.view.width, self.view.height - CGRectGetMaxY(navigationBar.frame)) style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookmarkEditTextFieldTableViewCell class]) bundle:nil] forCellReuseIdentifier:kBookmarkEditTextFieldCellIdentifier];
    
    _tableView.tableFooterView = [UIView new];
}

- (void)initData{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView reloadData];
}

#pragma mark - Handle NavigationItem Clicked

- (void)handleDoneItemClicked{
    BookmarkEditTextFieldTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *name = cell.textField.text;
    if (!name || [name isEqualToString:@""]) {
        [self.view showHUDWithMessage:@"文件夹名不能为空"];
        return;
    }
    
    WEAK_REF(self)
    [self.dataManager addBookmarkDirectoryWithName:name completion:^(BOOL success){
        STRONG_REF(self_)
        if (self__ && success) {
            [self__ exit];
            if (self__.completion) {
                self__.completion();
            }
        }
        else if (self__){
            [self__.view showHUDWithMessage:@"文件夹名不能重名"];
        }
    }];
}

- (void)exit{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BookmarkEditTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBookmarkEditTextFieldCellIdentifier];
    [cell.textField becomeFirstResponder];
    
    return cell;
}

@end
