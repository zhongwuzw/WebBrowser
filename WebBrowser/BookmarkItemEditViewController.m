//
//  BookmarkItemEditViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkItemEditViewController.h"
#import "BookmarkEditTextFieldTableViewCell.h"
#import "BookmarkDataManager.h"

static NSString *const kBookmarkItemEditSectionCellIdentifier = @"kBookmarkItemEditSectionCellIdentifier";

typedef NS_ENUM(NSUInteger, BookmarkItemTextField) {
    BookmarkItemTextFieldForTitle = 100,
    BookmarkItemTextFieldForURL
};

@interface BookmarkItemEditViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) BookmarkItemModel *itemModel;
@property (nonatomic, assign) BookmarkItemOperationKind operationKind;

@end

@implementation BookmarkItemEditViewController

#pragma mark - Dealloc

- (void)dealloc{
    [Notifier removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithDataManager:(BookmarkDataManager *)dataManager item:(BookmarkItemModel *)item sectionIndex:(NSIndexPath *)indexPath operationKind:(BookmarkItemOperationKind)kind completion:(BookmarkEditCompletion)completion{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.dataManager = dataManager;
        self.completion = completion;
        self.indexPath = indexPath;
        _finalIndexPath = indexPath;
        _operationKind = kind;
        _itemModel = [item copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Notifier addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)initUI{
    [super initUI];
    self.title = @"书签";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kBookmarkItemEditSectionCellIdentifier];
}

#pragma mark - TextField Input

- (void)textFieldTextDidChange:(NSNotification *)notify{
    UITextField *textField = [notify object];
    NSString *inputString = [textField text];
    
    switch (textField.tag) {
        case BookmarkItemTextFieldForTitle:
            self.itemModel.title = inputString;
            break;
        case BookmarkItemTextFieldForURL:
            self.itemModel.url = inputString;
            break;
        default:
            break;
    }
}

#pragma mark - Handle NavigationItem Clicked

- (void)handleDoneItemClicked{
    BookmarkItemModel *itemModel = self.itemModel;
    if (!itemModel.title || [itemModel.title isEqualToString:@""] || !itemModel.url || [itemModel.url isEqualToString:@""]) {
        [self.view showHUDWithMessage:@"标题或地址不能为空"];
        return;
    }
    
    WEAK_REF(self)
    BookmarkDataCompletion completion = ^(BOOL success){
        STRONG_REF(self_)
        if (self__ && success) {
            [self__ exit];
            if (self__.completion) {
                self__.completion();
            }
        }
        else if (self__){
            [self__.view showHUDWithMessage:@"操作失败"];
        }
    };
    
    if (self.operationKind == BookmarkItemOperationKindItemEdit) {
        [self.dataManager editBookmarkItemWithModel:self.itemModel oldIndexPath:self.indexPath finalIndexPath:self.finalIndexPath completion:^(BOOL success){
            completion(success);
        }];
    }
    else{
        [self.dataManager addBookmarkWithURL:self.itemModel.url title:self.itemModel.title sectionIndex:self.finalIndexPath.section completion:^(BOOL success){
            completion(success);
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return (section == 1) ? @"位置" : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (section == 0) ? 2 : [self.dataManager numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kBookmarkEditTextFieldCellIdentifier];
        UITextField *textField = [(BookmarkEditTextFieldTableViewCell *)cell textField];
        if (indexPath.row == 0) {
            [textField becomeFirstResponder];
            textField.placeholder = @"标题";
            textField.text = self.itemModel.title;
            textField.tag = BookmarkItemTextFieldForTitle;
        }
        else{
            textField.placeholder = @"地址";
            textField.text = self.itemModel.url;
            textField.tag = BookmarkItemTextFieldForURL;
        }
        textField.delegate = self;
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:kBookmarkItemEditSectionCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = [self.dataManager headerTitleForSection:indexPath.row];
        if (indexPath.row == self.indexPath.section) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row != self.finalIndexPath.section) {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.finalIndexPath.section inSection:1]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.finalIndexPath = [NSIndexPath indexPathForRow:self.indexPath.row inSection:indexPath.row];
    }
    
}

@end
