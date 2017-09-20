//
//  CardMainBottomView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/22.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardMainBottomView.h"

@interface CardMainBottomView ()

@property (nonatomic, strong) UIBarButtonItem * returnButton;
@property (nonatomic, strong) UIBarButtonItem * addButton;

@end

@implementation CardMainBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
    self.backgroundColor = [UIColor whiteColor];
    
    self.returnButton = [self createBottomToolBarButtonWithImage:@"card-return" tag:ReturnButtonClicked];
    
    self.addButton = [self createBottomToolBarButtonWithImage:@"card-add" tag:AddButtonClicked];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setItems:@[flexibleItem, self.returnButton, flexibleItem, self.addButton, flexibleItem]];
}

- (UIBarButtonItem *)createBottomToolBarButtonWithImage:(NSString *)imageName tag:(NSInteger)tag{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(handleButtonClickedWithButton:)];
    item.tag = tag;
    
    return item;
}

- (void)makeConstraintsWithButton:(UIButton *)button isLeft:(BOOL)isLeft{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutAttribute attribute = isLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self attribute:attribute multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
}

- (void)handleButtonClickedWithButton:(UIBarButtonItem *)button{
    if ([self.bottomDelegate respondsToSelector:@selector(cardBottomBtnClickedWithTag:)]) {
        [self.bottomDelegate cardBottomBtnClickedWithTag:button.tag];
    }
}

@end
