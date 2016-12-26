//
//  CardCollectionViewCell.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardCollectionViewCell.h"
#import "CardCollectionViewLayout.h"
#import "UIColor+ZWUtility.h"

@interface CardCollectionViewCell () <UIGestureRecognizerDelegate>

@end

@implementation CardCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect rect = self.bounds;
    rect.size.width -= 9;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10].CGPath;
    self.layer.shadowOffset = CGSizeMake(4, -2);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
}

- (void)commonInit{
    self.layer.speed = 0.8;
    self.backgroundColor = [UIColor randomColor];
//    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 100, 40)];
    [label setText:@"webSiteURL:www.baidu.com"];
    label.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:label];
}

@end
