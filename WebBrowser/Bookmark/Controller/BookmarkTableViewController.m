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
#import "BookmarkDirectoryEditViewController.h"
#import "BookmarkSectionTableViewCell.h"
#import "BookmarkItemEditViewController.h"

static CGFloat const kBookmarkTableHeaderViewHeader = 34;
static NSString *const kBookmarkTableViewCellIdentifier = @"kBookmarkTableViewCellIdentifier";
static NSString *const kBookmarkSectionTableViewCellIdentifier = @"kBookmarkSectionTableViewCellIdentifier";
static NSString *const kBookmarkTableViewHeaderFooterIdentifier = @"kBookmarkTableViewHeaderFooterIdentifier";
static NSString *const kEditToolBarItem = @"编辑";

typedef NS_ENUM(NSUInteger, BookmarkTableState) {
    BookmarkTableStateNormal,
    BookmarkTableStateSectionEdit,
    BookmarkTableStateBookmarkEdit,
};

@interface BookmarkTableViewController () <SectionHeaderViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) BookmarkDataManager *dataManager;
@property (nonatomic, strong) NSMutableArray<BookmarkSectionInfo *> *sectionInfoArray;
@property (nonatomic, assign) BookmarkTableState tableState;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

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
    [self addGesture];
}

- (void)initUI{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookmarkSectionHeaderView class]) bundle:nil]forHeaderFooterViewReuseIdentifier:kBookmarkTableViewHeaderFooterIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookmarkTableViewCell class]) bundle:nil] forCellReuseIdentifier:kBookmarkTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookmarkSectionTableViewCell class]) bundle:nil] forCellReuseIdentifier:kBookmarkSectionTableViewCellIdentifier];
    
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

- (void)addGesture{
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
    _longPressGesture.delegate = self;
    [self.tableView addGestureRecognizer:_longPressGesture];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self addToolbarNewDirectoryAndDoneBtn];
    }
    else{
        BookmarkTableState previousState = self.tableState;
        self.tableState = BookmarkTableStateNormal;
        if (previousState == BookmarkTableStateSectionEdit) {
            [self.tableView reloadData];
        }
        [self addToolbarEditBtn];
    }
}

#pragma mark - Handle Gesture

- (void)handleLongGesture:(UILongPressGestureRecognizer *)longGesture{
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint p = [longGesture locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        CGRect frame = CGRectNull;
        if (indexPath) {
            BookmarkSectionHeaderView *headerView = (BookmarkSectionHeaderView *)[self.tableView headerViewForSection:indexPath.section];
            frame = (headerView) ? headerView.frame : CGRectNull;
        }
        
        if (!indexPath || CGRectContainsPoint(frame, p)) {
            [self handleSectionLongGestureWithCGPoint:p];
        }
        else{
            [self handleCellLongGestureWithIndexPath:indexPath];
        }
    }
}

// edit bookmark item
- (void)handleCellLongGestureWithIndexPath:(NSIndexPath *)indexPath{
    BookmarkItemModel *itemModel = [self.dataManager bookmarkModelForRowAtIndexPath:indexPath];
    
    WEAK_REF(self)
    BookmarkItemEditViewController *editVC = [[BookmarkItemEditViewController alloc] initWithDataManager:self.dataManager item:itemModel sectionIndex:indexPath operationKind:BookmarkItemOperationKindItemEdit completion:^{
        STRONG_REF(self_)
        if (self__) {
            [self__.tableView reloadData];
        }
    }];
    
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:editVC];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

// edit bookmark directory
- (void)handleSectionLongGestureWithCGPoint:(CGPoint)point{
    NSInteger sections = [self.tableView numberOfSections];
    
    BookmarkSectionHeaderView *headerView;
    NSInteger index = NSNotFound;
    
    for (int i = 0; i < sections; i++) {
        BookmarkSectionHeaderView *hView = (BookmarkSectionHeaderView *)[self.tableView headerViewForSection:i];
        if (hView && CGRectContainsPoint(hView.frame, point)) {
            headerView = hView;
            index = i;
            break;
        }
    }
    
    if (headerView) {
        WEAK_REF(self)
        BookmarkDirectoryEditViewController *editVC = [[BookmarkDirectoryEditViewController alloc] initWithDataManager:self.dataManager sectionName:headerView.titleLabel.text sectionIndex:[NSIndexPath indexPathForRow:0 inSection:index] completion:^{
            STRONG_REF(self_)
            if (self__) {
                [self__.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        
        UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:editVC];
        [self presentViewController:navigationVC animated:YES completion:nil];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return !self.editing;
    }
    return NO;
}

#pragma mark - Handle ToolBar

- (void)handleEditBtnClicked{
    self.tableState = BookmarkTableStateBookmarkEdit;
    [self setEditing:YES animated:YES];
}

- (void)handleSectionEditBtnClicked{
    self.tableState = BookmarkTableStateSectionEdit;
    [self.sectionInfoArray enumerateObjectsUsingBlock:^(BookmarkSectionInfo *info, NSUInteger idx, BOOL *stop){
        info.open = NO;
    }];
    
    [self.tableView reloadData];
    [self setEditing:YES animated:YES];
}

- (void)handleDoneBtnClicked{
    [self setEditing:NO animated:YES];
}

- (void)handleNewDirectoryBtnClicked{
    WEAK_REF(self)
    BookmarkDirectoryEditViewController *editVC = [[BookmarkDirectoryEditViewController alloc] initWithDataManager:self.dataManager completion:^{
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
    [self presentViewController:navigationVC animated:YES completion:nil];
}

- (void)addToolbarEditBtn{
    UIBarButtonItem *sectionEditItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑文件夹" style:UIBarButtonItemStylePlain target:self action:@selector(handleSectionEditBtnClicked)];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑书签" style:UIBarButtonItemStylePlain target:self action:@selector(handleEditBtnClicked)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[sectionEditItem, flexibleItem, editItem] animated:YES];
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
    if (self.tableState == BookmarkTableStateSectionEdit) {
        return 1;
    }
    BookmarkSectionInfo *sectionInfo = (section < self.sectionInfoArray.count) ? self.sectionInfoArray[section] : nil;
    return sectionInfo.open ? [self.dataManager numberOfRowsInSection:section] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if (self.tableState == BookmarkTableStateSectionEdit) {
        cell = [tableView dequeueReusableCellWithIdentifier:kBookmarkSectionTableViewCellIdentifier];
        NSString *title = [self.dataManager headerTitleForSection:indexPath.section];
        [(BookmarkSectionTableViewCell *)cell titleLabel].text = title;
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:kBookmarkTableViewCellIdentifier];
        
        BookmarkItemModel *itemModel = [self.dataManager bookmarkModelForRowAtIndexPath:indexPath];
        cell.textLabel.text = itemModel.title;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.tableState == BookmarkTableStateSectionEdit) {
        return nil;
    }
    
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
    return self.editing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.tableState == BookmarkTableStateSectionEdit) {
            [self.dataManager deleteSectionAtIndexPath:indexPath completion:^(BOOL success){
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }];
        }
        else{
            [self.dataManager deleteRowAtIndexPath:indexPath completion:^(BOOL success){
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    WEAK_REF(self)
    if (self.tableState == BookmarkTableStateSectionEdit) {
        [self.dataManager moveSectionAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath completion:nil];
    }
    else{
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
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableState == BookmarkTableStateSectionEdit) {
        return kBookmarkTableHeaderViewHeader;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.tableState == BookmarkTableStateSectionEdit) {
        return 0;
    }
    return kBookmarkTableHeaderViewHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!tableView.editing) {
        BookmarkItemModel *model = [self.dataManager bookmarkModelForRowAtIndexPath:indexPath];
        
        if (model.url.length > 0) {
            [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[model.url] key:DelegateManagerBrowserContainerLoadURL];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

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
