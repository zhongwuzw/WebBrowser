//
//  HistoryTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/20.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "HistoryDataManager.h"

static NSString *const kHistoryTableViewCellIdentifier = @"kHistoryTableViewCellIdentifier";
static NSString *const kHistoryTableViewHeaderFooterIdentifier = @"kHistoryTableViewHeaderFooterIdentifier";
static CGFloat const kHistoryTableHeaderViewHeader = 34;

@interface HistoryTableViewController ()

@property (nonatomic, strong) HistoryDataManager *historyDataManager;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
}

- (void)initData{
    WEAK_REF(self)
    _historyDataManager = [[HistoryDataManager alloc] initWithCompletion:^{
        STRONG_REF(self_)
        if (self__) {
            [self__.tableView reloadData];
        }
    }];
    self.tableView.sectionHeaderHeight = kHistoryTableHeaderViewHeader;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kHistoryTableViewHeaderFooterIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.historyDataManager numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.historyDataManager numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kHistoryTableViewCellIdentifier];
    }
    
    HistoryItemModel *itemModel = [self.historyDataManager historyModelForRowAtIndexPath:indexPath];
    
    cell.textLabel.text = itemModel.title;
    cell.detailTextLabel.text = itemModel.url;
    
    return cell;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHistoryTableViewHeaderFooterIdentifier];
    
    NSString *title = [self.historyDataManager headerTitleForSection:section];
    view.textLabel.text = title;
    
    return view;
}

@end
