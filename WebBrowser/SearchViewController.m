//
//  SearchViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/27.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchInputView.h"
#import "HTTPClient+SearchSug.h"
#import "BaiduSugResponseModel.h"
#import "SearchTableViewCell.h"
#import "HttpHelper.h"
#import "KeyboardHelper.h"

#define SEARCH_INPUTVIEW_HEIGHT 76
static NSString * const CELL = @"CELL";

@interface SearchViewController ()<UITableViewDelegate, UITableViewDataSource, KeyboardHelperDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SearchInputView *searchInputView;
@property (nonatomic, strong) NSURLSessionDataTask *bdRecoTask;
@property (nonatomic, copy) NSArray *searchResultArray;
@property (nonatomic, assign) BOOL isTextChanged;

@end

@implementation SearchViewController

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, self.view.width, CGRectGetMinY(self.searchInputView.frame) - STATUS_BAR_HEIGHT) style:UITableViewStylePlain];
        [self.view insertSubview:_tableView belowSubview:self.searchInputView];
        
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SearchTableViewCell class]) bundle:nil] forCellReuseIdentifier:CELL];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[KeyboardHelper sharedInstance] addDelegate:self];
    
    [self commonUIInit];
}

- (void)commonUIInit{
    self.view.backgroundColor = [UIColor whiteColor];
    self.searchInputView = ({
        SearchInputView *inputView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SearchInputView class]) owner:nil options:nil] objectAtIndex:0];
        inputView.frame = CGRectMake(self.view.bounds.origin.x, self.view.height - SEARCH_INPUTVIEW_HEIGHT, self.view.width, SEARCH_INPUTVIEW_HEIGHT);
        [self.view addSubview:inputView];
        
        [Notifier addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
        
        [inputView.textField setText:self.origTextFieldString];
        inputView.slider.enabled = (self.origTextFieldString.length > 0);
        
        inputView;
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchInputView.textField becomeFirstResponder];
}

- (void)textFieldTextDidChange:(NSNotification *)notify{
    self.isTextChanged = YES;
    UITextField *textField = [notify object];
    if (textField.text.length > 0) {
        self.searchInputView.slider.enabled = YES;
        if (self.bdRecoTask && (self.bdRecoTask.state == NSURLSessionTaskStateRunning || self.bdRecoTask.state == NSURLSessionTaskStateSuspended)) {
            [self.bdRecoTask cancel];
        }
        self.bdRecoTask = [[HTTPClient sharedInstance] getSugWithKeyword:textField.text success:^(NSURLSessionDataTask *task, BaseResponseModel *model){
            BaiduSugResponseModel *bdModel = (BaiduSugResponseModel *)model;
            self.searchResultArray = bdModel.sugArray;
            [self.tableView reloadData];
        }fail:^(NSURLSessionDataTask *task, BaseResponseModel *model){
            ;
        }];
    }
    else{
        self.searchInputView.slider.enabled = NO;
    }
}

#pragma mark - KeyboardHelperDelegate

- (void)keyboardHelper:(KeyboardHelper *)keyboardHelper keyboardWillShowWithState:(KeyboardState *)state{
    [self changeSearchInputViewPoint:state];
}

- (void)keyboardHelper:(KeyboardHelper *)keyboardHelper keyboardWillHideWithState:(KeyboardState *)state{
    [self changeSearchInputViewPoint:state];
}

- (void)changeSearchInputViewPoint:(KeyboardState *)state{
    NSDictionary *userInfo = [state userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;  // 得到键盘弹出后的键盘视图所在y坐标
    
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:state.animationDuration animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:state.animationCurve];
        
        self.searchInputView.center = CGPointMake(self.searchInputView.centerX, keyBoardEndY - self.searchInputView.height/2.0);
        if (self.isTextChanged) {
            self.tableView.height = CGRectGetMinY(self.searchInputView.frame) - STATUS_BAR_HEIGHT;
        }
    }];
}

#pragma mark - UITableViewDataSource Method

- (SearchTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
    
    [cell updateCellWithString:self.searchResultArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResultArray.count;
}

#pragma mark - UITableViewDelegate Method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SearchTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *text = [cell cellText];
    if (text) {
        [[DelegateManager sharedInstance] performSelector:NSSelectorFromString(@"browserContainerViewLoadWebViewWithSug:") arguments:@[text] key:DelegateManagerBrowserContainerLoadURL];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)dealloc{
    [Notifier removeObserver:self];
}

@end
