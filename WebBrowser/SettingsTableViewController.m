//
//  SettingsTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingActivityTableViewCell.h"

#define CELL_IDENTIFIER @"CELL_IDENTIFIER"

@interface SettingsTableViewController ()

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, copy) NSArray *selArray;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataArray = @[@"清除缓存"];
    self.dataArray = @[@"cleanCache"];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingActivityTableViewCell class]) bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
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

- (void)handleTableViewSelectAt:(NSInteger)index{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确定清除缓存？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){}];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    NSString *sel = self.selArray[indexPath.row];
    if ([self respondsToSelector:NSSelectorFromString(sel)]) {
        [self performSelector:NSSelectorFromString(sel)];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self handleTableViewSelectAt:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SEL Method

- (void)cleanCache{
    
}

@end
