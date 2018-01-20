//
//  HomePageView.m
//  WebBrowser
//
//  Created by 钟武 on 2017/10/26.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HomePageView.h"
#import "SearchViewController.h"
#import "BrowserViewController.h"

@interface HomePageView()

@end

@implementation HomePageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView{
    self.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    UIButton *searchButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"baidu_search_frame"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"baidu_search_frame"] forState:UIControlStateHighlighted];
        [self addSubview:btn];
        
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[btn]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        
        [btn addTarget:self action:@selector(handleSearchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        btn;
    });
    
    UIImageView *logoImage = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"baidu_logo"]];
        [self addSubview:imageView];
        
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.f constant:183.f]];
        
        imageView;
    });
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[logoImage(57)]-17-[searchButton(45)]-140-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchButton,logoImage)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:logoImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:searchButton attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.f]];
}

- (void)handleSearchButtonClicked{
    [Notifier postNotification:[NSNotification notificationWithName:kExpandHomeToolBarNotification object:nil]];
    SearchViewController *searchVC = [SearchViewController new];
    searchVC.origTextFieldString = @"";
    [[BrowserVC navigationController] pushViewController:searchVC animated:NO];
}

@end
