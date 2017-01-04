//
//  SearchViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/27.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchInputView.h"

#define SEARCH_INPUTVIEW_HEIGHT 45

@interface SearchViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SearchInputView *searchInputView;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSearchInputViewPoint:) name:UIKeyboardWillShowNotification object:nil];
    
    [self commonUIInit];
}

- (void)commonUIInit{
    self.searchInputView = ({
        SearchInputView *inputView = [[SearchInputView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.height - SEARCH_INPUTVIEW_HEIGHT, self.view.width, SEARCH_INPUTVIEW_HEIGHT)];
        [self.view addSubview:inputView];
        inputView;
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}

- (void)changeSearchInputViewPoint:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;  // 得到键盘弹出后的键盘视图所在y坐标
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        
        self.searchInputView.center = CGPointMake(self.searchInputView.centerX, keyBoardEndY - STATUS_BAR_HEIGHT - self.searchInputView.height/2.0);   // keyBoardEndY的坐标包括了状态栏的高度，要减去
        
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
