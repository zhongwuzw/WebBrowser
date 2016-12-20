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

- (void)commonInit{
    self.layer.speed = 0.8;
    self.backgroundColor = [UIColor randomColor];
}

@end
