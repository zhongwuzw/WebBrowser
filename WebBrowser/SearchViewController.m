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
@property (nonatomic, strong) KeyboardState *keyboardState;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
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
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.view addSubview:tableView];
        
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tableView]-0-[_searchInputView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView,_searchInputView)]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f]];
        [tableView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        
        tableView.backgroundColor = [UIColor whiteColor];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SearchTableViewCell class]) bundle:nil] forCellReuseIdentifier:CELL];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        tableView;
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchInputView.textField becomeFirstResponder];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeSearchInputViewPoint:self.keyboardState];
    });
}

- (void)cancelRecoTaskIfNeeded{
    if (self.bdRecoTask && (self.bdRecoTask.state == NSURLSessionTaskStateRunning || self.bdRecoTask.state == NSURLSessionTaskStateSuspended)) {
        [self.bdRecoTask cancel];
    }
}

- (void)textFieldTextDidChange:(NSNotification *)notify{
    UITextField *textField = [notify object];
    if (textField.text.length > 0) {
        self.searchInputView.slider.enabled = YES;
        
        [self cancelRecoTaskIfNeeded];
        
        WEAK_REF(self)
        self.bdRecoTask = [[HTTPClient sharedInstance] getSugWithKeyword:textField.text success:^(NSURLSessionDataTask *task, BaseResponseModel *model){
            STRONG_REF(self_)
            if (self__) {
                BaiduSugResponseModel *bdModel = (BaiduSugResponseModel *)model;
                self__.searchResultArray = bdModel.sugArray;
                [self__.tableView reloadData];
            }
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
    self.keyboardState = state;
    
    CGFloat keyBoardEndY = self.view.height - [state intersectionHeightForView:self.view];
    
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:state.animationDuration animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:state.animationCurve];
        
        self.searchInputView.center = CGPointMake(self.searchInputView.centerX, keyBoardEndY - self.searchInputView.height/2.0f);
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
        [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[text] key:DelegateManagerBrowserContainerLoadURL];
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)dealloc{
    [self cancelRecoTaskIfNeeded];
    [Notifier removeObserver:self];
    DDLogDebug(@"SearchViewController dealloc");
}

@end
