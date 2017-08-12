//
//  SettingsCollectionViewCell.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/26.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "SettingsCollectionViewCell.h"

@implementation SettingsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.textLabel = [UILabel new];
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.textLabel];
        self.imageView = [UIImageView new];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
        self.backgroundColor = [UIColor clearColor];
        self.imageView.image = nil;
        self.selectedBackgroundView = [UIView new];
        [self addConstraints];
    }
    return self;
}

- (UIColor *)inversedTintColor
{
    CGFloat white = 0, alpha = 0;
    [self.tintColor getWhite:&white alpha:&alpha];
    return [UIColor colorWithWhite:1.2f - white alpha:alpha];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    self.textLabel.textColor = self.tintColor;
    self.selectedBackgroundView.backgroundColor = self.tintColor;
    self.textLabel.highlightedTextColor = [self inversedTintColor];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected)
    {
        self.imageView.tintColor = [self inversedTintColor];
        NSUInteger len = [self.textLabel.attributedText length];
        if (len > 0) {
            NSMutableAttributedString *attrStr = [self.textLabel.attributedText mutableCopy];
            [attrStr addAttribute:NSForegroundColorAttributeName value:[self inversedTintColor] range:NSMakeRange(0, len)];
            [self.textLabel setAttributedText:attrStr];
        }
    }
    else
    {
        self.imageView.tintColor = self.tintColor;
    }
}
    
- (void)addConstraints{
    NSDictionary *views = @{@"text":self.textLabel, @"image":self.imageView};
    
    foreach(v, [views allValues]) {
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    }
    
    CGFloat margin = 20;
    
    NSString *vfs = nil;
    vfs = @"H:|[text]-(15)-[image]";
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-margin]];
    [self.imageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfs options:0 metrics:nil views:views]];
}

@end
