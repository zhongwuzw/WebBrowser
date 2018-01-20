//
//  HistoryTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/20.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "HistoryDataManager.h"
#import "DelegateManager.h"
#import "BrowserViewController.h"

static NSString *const kHistoryTableViewCellIdentifier = @"kHistoryTableViewCellIdentifier";
static NSString *const kHistoryTableViewHeaderFooterIdentifier = @"kHistoryTableViewHeaderFooterIdentifier";
static CGFloat const kHistoryTableHeaderViewHeader = 34;
static CGFloat const kHistoryTableViewThreshold = 50;
static NSString *const kHistoryTableViewContentOffset = @"contentOffset";
static NSString *const kHistoryTableViewContentSize = @"contentSize";

@interface HistoryTableViewController ()

@property (nonatomic, strong) HistoryDataManager *historyDataManager;
@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, weak) UILabel *bottomNoMoreLabel;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initObserver];
}

- (void)initUI{
    self.tableView.sectionHeaderHeight = kHistoryTableHeaderViewHeader;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kHistoryTableViewHeaderFooterIdentifier];
    
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"清除所有" style:UIBarButtonItemStylePlain target:self action:@selector(handleClearAllHistory)];
    self.navigationItem.rightBarButtonItem = clearItem;
    self.title = @"历史";
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.tableView addGestureRecognizer:longGesture];
}

- (void)initData{
    self.isLoading = YES;
    WEAK_REF(self)
    _historyDataManager = [[HistoryDataManager alloc] initWithCompletion:^(BOOL isNoMoreData){
        STRONG_REF(self_)
        if (self__) {
            self__.noMoreData = isNoMoreData;
            [self__ addNoMoreDataViewIfNeeded];
            [self__.tableView reloadData];
            self__.isLoading = NO;
        }
    }];
}

- (void)initObserver{
    [self.tableView addObserver:self forKeyPath:kHistoryTableViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
    [self.tableView addObserver:self forKeyPath:kHistoryTableViewContentSize options:NSKeyValueObservingOptionNew context:nil];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longGesture{
    if (longGesture.state == UIGestureRecognizerStateRecognized) {
        CGPoint p = [longGesture locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        
        [self handleLongPressGestureForIndexPath:indexPath];
    }
}

- (void)handleLongPressGestureForIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath) {
        return;
    }
    
    HistoryItemModel *model = [self.historyDataManager historyModelForRowAtIndexPath:indexPath];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *copyTitleAction = [UIAlertAction actionWithTitle:@"拷贝标题" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self copyToPasteBoardWithString:model.title isURL:NO];
    }];
    
    UIAlertAction *copyURLAction = [UIAlertAction actionWithTitle:@"拷贝链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self copyToPasteBoardWithString:model.url isURL:YES];
    }];
    
    UIAlertAction *openInNewWindowAction = [UIAlertAction actionWithTitle:@"新窗口打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSURL *url = [NSURL URLWithString:model.url];
        if (url) {
            [self.navigationController popViewControllerAnimated:NO];
            NSNotification *notify = [NSNotification notificationWithName:kOpenInNewWindowNotification object:self userInfo:@{@"url": url}];
            [Notifier postNotification:notify];
        }
    }];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.view showHUDWithMessage:@"Yep, 就是不想实现!"];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [@[copyTitleAction, copyURLAction, openInNewWindowAction, shareAction, cancelAction] enumerateObjectsUsingBlock:^(UIAlertAction *action, NSUInteger idx, BOOL *stop){
        [alert addAction:action];
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)copyToPasteBoardWithString:(NSString *)str isURL:(BOOL)isURL{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    BOOL isSuccess = YES;
    if (isURL) {
        NSURL *url = [NSURL URLWithString:str];
        if (url) {
            pasteBoard.URL = url;
        }
        else{
            isSuccess = NO;
        }
    }
    else if(str.length > 0) {
        pasteBoard.string = str;
    }
    else{
        isSuccess = NO;
    }
    [[BrowserVC navigationController].view showHUDAtBottomWithMessage:isSuccess ? @"拷贝成功":@"拷贝失败"];
}

- (void)handleClearAllHistory{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确定删除所有历史记录？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [self.historyDataManager deleleAllHistoryRecords];
        self.noMoreData = YES;
        [self addNoMoreDataViewIfNeeded];
        [self.tableView reloadData];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addNoMoreDataViewIfNeeded{
    if (self.noMoreData && !self.bottomNoMoreLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setText:@"没有更多历史访问记录"];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self.tableView addSubview:label];
        self.bottomNoMoreLabel = label;
    }
}

- (void)reloadBeforeHistorySectionIfNeeded:(NSArray<NSIndexPath *> *)indexPaths{
    if (indexPaths.count > 0) {
        NSInteger section = self.tableView.numberOfSections - 1;
        if (section >= 0) {
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![object isKindOfClass:[UITableView class]]) {
        return;
    }
    
    if ([keyPath isEqualToString:kHistoryTableViewContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    }
    else if ([keyPath isEqualToString:kHistoryTableViewContentSize] && self.bottomNoMoreLabel){
        [self scrollViewContentSizeDidChange:change];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{
    CGFloat yContentHeight = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue].height;
    self.bottomNoMoreLabel.frame = CGRectMake(0, yContentHeight, self.tableView.width, 30);
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    if (_isLoading) {
        return;
    }
    
    CGFloat yOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue].y;
    if (yOffset > 0 && yOffset + self.tableView.height + kHistoryTableViewThreshold > self.tableView.contentSize.height) {
        if (!self.noMoreData) {
            self.isLoading = YES;
            WEAK_REF(self)
            [self.historyDataManager getMoreDataWithCompletion:^(NSArray<NSIndexPath *> *indexPaths, BOOL isNoMoreData){
                STRONG_REF(self_)
                if (self__) {
                    self__.noMoreData = isNoMoreData;
                    [self__ addNoMoreDataViewIfNeeded];
                    [self__ reloadBeforeHistorySectionIfNeeded:indexPaths];
                    self__.isLoading = NO;
                }
            }];
        }
    }
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kHistoryTableViewCellIdentifier];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HistoryItemModel *itemModel = [self.historyDataManager historyModelForRowAtIndexPath:indexPath];
    
    [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[itemModel.url] key:DelegateManagerBrowserContainerLoadURL];
    [self.navigationController popViewControllerAnimated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WEAK_REF(self)
        [self.historyDataManager deleteRowAtIndexPath:indexPath completion:^(BOOL success){
            STRONG_REF(self_)
            if (self__ && success) {
                [self__.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Dealloc

- (void)dealloc{
    [self.tableView removeObserver:self forKeyPath:kHistoryTableViewContentOffset];
    [self.tableView removeObserver:self forKeyPath:kHistoryTableViewContentSize];
    DDLogDebug(@"HistoryTableViewController dealloc");
}

@end
