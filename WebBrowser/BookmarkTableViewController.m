//
//  BookmarkTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkTableViewController.h"
#import "BookmarkDataManager.h"
#import "BookmarkSectionHeaderView.h"
#import "BookmarkSectionInfo.h"
#import "BookmarkTableViewCell.h"
#import "BookmarkEditViewController.h"

static CGFloat const kBookmarkTableHeaderViewHeader = 34;
static NSString *const kBookmarkTableViewCellIdentifier = @"kBookmarkTableViewCellIdentifier";
static NSString *const kBookmarkTableViewHeaderFooterIdentifier = @"kBookmarkTableViewHeaderFooterIdentifier";
static NSString *const kEditToolBarItem = @"编辑";

@interface BookmarkTableViewController () <SectionHeaderViewDelegate>

@property (nonatomic, strong) BookmarkDataManager *dataManager;
@property (nonatomic, strong) NSMutableArray<BookmarkSectionInfo *> *sectionInfoArray;

@end

@implementation BookmarkTableViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
}

- (void)initUI{
    self.tableView.sectionHeaderHeight = kBookmarkTableHeaderViewHeader;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookmarkSectionHeaderView class]) bundle:nil]forHeaderFooterViewReuseIdentifier:kBookmarkTableViewHeaderFooterIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookmarkTableViewCell class]) bundle:nil] forCellReuseIdentifier:kBookmarkTableViewCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addToolbarEditBtn];
    self.title = @"收藏";
}

- (void)initData{
    self.sectionInfoArray = [NSMutableArray array];
    WEAK_REF(self)
    self.dataManager = [[BookmarkDataManager alloc] initWithCompletion:^(NSArray<BookmarkSectionModel *> *array){
        STRONG_REF(self_)
        if (self__) {
            [array enumerateObjectsUsingBlock:^(BookmarkSectionModel *model, NSUInteger idx, BOOL *stop){
                BookmarkSectionInfo *sectionInfo = [BookmarkSectionInfo new];
                sectionInfo.open = NO;
                [self__.sectionInfoArray addObject:sectionInfo];
            }];
            
            [self__.tableView reloadData];
        }
    }];
}

#pragma mark - Handle ToolBar

- (void)handleEditBtnClicked{
    [self addToolbarNewDirectoryAndDoneBtn];
    
    [self.tableView setEditing:YES animated:YES];
}

- (void)handleDoneBtnClicked{
    [self addToolbarEditBtn];
    [self.tableView setEditing:NO animated:YES];
}

- (void)handleNewDirectoryBtnClicked{
    WEAK_REF(self)
    BookmarkEditViewController *editVC = [[BookmarkEditViewController alloc] initWithDataManager:self.dataManager completion:^{
        STRONG_REF(self_)
        if (self__) {
            NSInteger section = [self__.dataManager numberOfSections];
            //section always greater than or equal to 0
            BookmarkSectionInfo *sectionInfo = [BookmarkSectionInfo new];
            sectionInfo.open = NO;
            [self__.sectionInfoArray addObject:sectionInfo];
            [self__.tableView insertSections:[NSIndexSet indexSetWithIndex:section - 1] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
    
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:editVC];
    [self presentViewController:navigationVC animated:YES completion:^{
        ;
    }];
}

- (void)addToolbarEditBtn{
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(handleEditBtnClicked)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[flexibleItem, editItem] animated:YES];
}

- (void)addToolbarNewDirectoryAndDoneBtn{
    UIBarButtonItem *newDirectoryItem = [[UIBarButtonItem alloc] initWithTitle:@"新文件夹" style:UIBarButtonItemStylePlain target:self action:@selector(handleNewDirectoryBtnClicked)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self  action:@selector(handleDoneBtnClicked)];
    [self setToolbarItems:@[newDirectoryItem, flexibleItem, doneItem] animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataManager numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BookmarkSectionInfo *sectionInfo = (section < self.sectionInfoArray.count) ? self.sectionInfoArray[section] : nil;
    return sectionInfo.open ? [self.dataManager numberOfRowsInSection:section] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BookmarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBookmarkTableViewCellIdentifier];
    
    BookmarkItemModel *itemModel = [self.dataManager bookmarkModelForRowAtIndexPath:indexPath];
    cell.textLabel.text = itemModel.title;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    BookmarkSectionHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kBookmarkTableViewHeaderFooterIdentifier];
    
    NSString *title = [self.dataManager headerTitleForSection:section];
    view.titleLabel.text = title;
    view.section = section;
    view.delegate = self;
    if (section < self.sectionInfoArray.count) {
        view.diclosureButton.selected = self.sectionInfoArray[section].open;
    }
    
    return view;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataManager deleteRowAtIndexPath:indexPath completion:^(BOOL success){
            if (success) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    WEAK_REF(self)
    [self.dataManager moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath completion:^(BOOL success){
        STRONG_REF(self_)
        if (self__ && success && sourceIndexPath.section != destinationIndexPath.section && destinationIndexPath.section <  self__.sectionInfoArray.count && !self__.sectionInfoArray[destinationIndexPath.section].open) {
            BookmarkSectionHeaderView *headerView = (BookmarkSectionHeaderView *)[tableView headerViewForSection:destinationIndexPath.section];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [headerView toggleOpenWithUserAction:NO];
                [self__ sectionHeaderView:headerView sectionOpened:destinationIndexPath.section isMove:YES];
            });
        }
    }];
}

#pragma mark - UITableViewDelegate

#pragma mark - SectionHeaderViewDelegate

- (void)sectionHeaderView:(BookmarkSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened isMove:(BOOL)isMove {
    if (sectionOpened >= self.sectionInfoArray.count) {
        return;
    }
    
    NSInteger countOfRowsToInsert = [self.dataManager numberOfRowsInSection:sectionOpened];
    BookmarkSectionInfo *sectionInfo = self.sectionInfoArray[sectionOpened];
    sectionInfo.open = YES;
    
    if (isMove) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionOpened] withRowAnimation:UITableViewRowAnimationFade];
        return;
    }
    
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    if (countOfRowsToInsert) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (void)sectionHeaderView:(BookmarkSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    BookmarkSectionInfo *sectionInfo = (sectionClosed < self.sectionInfoArray.count) ? self.sectionInfoArray[sectionClosed] : nil;
    sectionInfo.open = NO;
    
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

#pragma mark - dealloc

- (void)dealloc{
    DDLogDebug(@"%@ dealloced",NSStringFromClass([self class]));
}

@end
