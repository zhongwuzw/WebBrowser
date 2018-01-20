//
//  FindInPageBar.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/17.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "FindInPageBar.h"

@interface FindInPageBar ()

@property (nonatomic, strong) UITextField *searchText;
@property (nonatomic, strong) UILabel *matchCountView;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation FindInPageBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = [UIColor whiteColor];
    
    self.searchText = ({
        UITextField *textField = [UITextField new];
        [textField addTarget:self action:@selector(handleTextChange:) forControlEvents:UIControlEventEditingChanged];
        textField.textColor = UIColorFromRGB(0xe66000);
        textField.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        textField.returnKeyType = UIReturnKeySearch;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:textField];
        
        textField;
    });
    
    self.matchCountView = ({
        UILabel *matchCountView = [UILabel new];
        matchCountView.textColor = [UIColor lightGrayColor];
        matchCountView.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        matchCountView.hidden = YES;
        matchCountView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:matchCountView];
        
        matchCountView;
    });
    
    self.previousButton = ({
        UIButton *previousButton = [UIButton new];
        [previousButton setImage:[UIImage imageNamed:@"find_previous"] forState:UIControlStateNormal];
        [previousButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [previousButton addTarget:self action:@selector(handleDidFindPrevious:) forControlEvents:UIControlEventTouchUpInside];
        previousButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:previousButton];
        
        previousButton;
    });
    
    self.nextButton = ({
        UIButton *nextButton = [UIButton new];
        [nextButton setImage:[UIImage imageNamed:@"find_next"] forState:UIControlStateNormal];
        [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(handleDidFindNext:) forControlEvents:UIControlEventTouchUpInside];
        nextButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:nextButton];
        
        nextButton;
    });
    
    UIButton *closeButton = [UIButton new];
    [closeButton setImage:[UIImage imageNamed:@"find_close"] forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(handleDidPressClose:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:closeButton];
    
    UIView *topBorder = [UIView new];
    topBorder.backgroundColor = UIColorFromRGB(0xEEEEEE);
    topBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:topBorder];
    
    //搞个自动布局要这么多行，多的话还是使轮子吧，sigh
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_searchText]-0-[_matchCountView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_searchText,_matchCountView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_searchText]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_searchText)]];
    [_searchText setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_searchText setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [_matchCountView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_matchCountView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_matchCountView]-0-[_previousButton]-0-[_nextButton]-0-[closeButton]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_matchCountView,_previousButton,_nextButton,closeButton)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_matchCountView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_previousButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_previousButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_previousButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nextButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nextButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_nextButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.f]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[topBorder]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topBorder)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[topBorder(1)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topBorder)]];
}

#pragma mark - setter & getter

- (void)setCurrentResult:(NSInteger)currentResult{
    if (_currentResult != currentResult) {
        _currentResult = currentResult;
        _matchCountView.text = [NSString stringWithFormat:@"%ld/%ld",(long)currentResult,(long)_totalResults];
    }
}

- (void)setTotalResults:(NSInteger)totalResults{
    if (_totalResults != totalResults) {
        _totalResults = totalResults;
        _previousButton.enabled = (totalResults > 1);
        _nextButton.enabled = _previousButton.enabled;
    }
}

- (NSString *)text{
    return _searchText.text;
}

- (void)setText:(NSString *)text{
    _searchText.text = text;
    [self handleTextChange:_searchText];
}

#pragma mark - Target Handler

- (void)handleTextChange:(UITextField *)sender{
    self.matchCountView.hidden = !self.searchText.text.length;
    [[DelegateManager sharedInstance] performSelector:@selector(findInPage:didTextChange:) arguments:@[self, self.searchText.text ? self.searchText.text : @""] key:DelegateManagerFindInPageBarDelegate];
}

- (void)handleDidFindPrevious:(UIButton *)sender{
    [[DelegateManager sharedInstance] performSelector:@selector(findInPage:didFindPreviousWithText:) arguments:@[self, self.searchText.text ? self.searchText.text : @""] key:DelegateManagerFindInPageBarDelegate];
}

- (void)handleDidFindNext:(UIButton *)sender{
    [[DelegateManager sharedInstance] performSelector:@selector(findInPage:didFindNextWithText:) arguments:@[self, self.searchText.text ? self.searchText.text : @""] key:DelegateManagerFindInPageBarDelegate];
}

- (void)handleDidPressClose:(UIButton *)sender{
    [[DelegateManager sharedInstance] performSelector:@selector(findInPageDidPressClose:) arguments:@[self] key:DelegateManagerFindInPageBarDelegate];
}

- (BOOL)becomeFirstResponder{
    [self.searchText becomeFirstResponder];
    return [super becomeFirstResponder];
}

@end
