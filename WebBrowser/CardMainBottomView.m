//
//  CardMainBottomView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/22.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardMainBottomView.h"

@interface CardMainBottomView ()

@property (nonatomic, strong) UIButton * returnButton;
@property (nonatomic, strong) UIButton * addButton;

@end

@implementation CardMainBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
    self.returnButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:button];
        button.tag = ReturnButtonClicked;
        [self makeConstraintsWithButton:button isLeft:YES];
        [button addTarget:self action:@selector(handleButtonClickedWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"card-return"] forState:UIControlStateNormal];
        
        button;
    });
    
    self.addButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:button];
        button.tag = AddButtonClicked;
        [self makeConstraintsWithButton:button isLeft:NO];
        [button addTarget:self action:@selector(handleButtonClickedWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"card-add"] forState:UIControlStateNormal];
        button;
    });
}

- (void)makeConstraintsWithButton:(UIButton *)button isLeft:(BOOL)isLeft{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = isLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self attribute:attribute multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
}

- (void)handleButtonClickedWithButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(cardBottomBtnClickedWithTag:)]) {
        [self.delegate cardBottomBtnClickedWithTag:button.tag];
    }
}

@end
