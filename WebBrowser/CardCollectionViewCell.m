//
//  CardCollectionViewCell.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardCollectionViewCell.h"
#import "UIColor+ZWUtility.h"
#import "UIImage+ZWUtility.h"
#import "TabManager.h"

#define Cell_Corner_Radius 10

@interface CardCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGFloat originTouchX;

@end

@implementation CardCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

//- (void)layoutSubviews{
//    [super layoutSubviews];
//    
////    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
////    self.contentView.layer.shadowOffset = CGSizeMake(0.0f, -20.0f);
////    self.contentView.layer.shadowOpacity = 0.6f;
////    self.contentView.layer.shadowRadius = 20.0f;
////    self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.contentView.bounds].CGPath;
////    self.contentView.layer.shouldRasterize = YES;
////    
////    CGRect rect = self.bounds;
////    rect.size.width -= 9;
////    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:Cell_Corner_Radius].CGPath;
////    self.layer.shadowOffset = CGSizeMake(4, -2);
////    self.layer.shadowOpacity = 0.5f;
////    self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f].CGColor;
//}

- (void)commonInit{
//    self.backgroundColor = UIColorFromRGB(0xE6E6E7);
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.clipsToBounds = YES;
//    self.layer.cornerRadius = Cell_Corner_Radius;
    
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        
        imageView;
    });

    UIImageView *closeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card-delete"]];
    [self.contentView addSubview:closeImage];
    
    closeImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[closeImage(22)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(closeImage)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[closeImage(22)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(closeImage)]];
}

- (void)updateWithWebModel:(WebModel *)webModel{
    //because of user may operate on webView,so needs update image every time.
    CGRect rect = self.imageView.bounds;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!webModel.isImageProcessed) {
            UIImage *finalImage;
            finalImage = [webModel.image getCornerImageWithFrame:rect cornerRadius:0 text:webModel.title atPoint:CGPointMake(15, 5)];
            webModel.image = finalImage;
            webModel.isImageProcessed = YES;
            
        }
        dispatch_main_safe_async(^{
            [self.imageView setImage:webModel.image];
        })
    });
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect rect = CGRectMake(self.contentView.width - Card_Cell_Close_Width, 0, Card_Cell_Close_Width, Card_Cell_Close_Height);
    if (CGRectContainsPoint(rect, point)) {
        if (self.closeBlock)
        {
            self.closeBlock([self.collectionView indexPathForCell:self]);
            self.closeBlock = nil;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
