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
#import "UIImage+ZWUtility.h"
#import "TabManager.h"

#define Cell_Corner_Radius 10

@interface CardCollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureReg;
@property (nonatomic, assign) CGFloat originTouchX;

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
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:Cell_Corner_Radius].CGPath;
    self.layer.shadowOffset = CGSizeMake(4, -2);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
}

- (void)commonInit{
    self.backgroundColor = UIColorFromRGB(0xE6E6E7);
    self.layer.cornerRadius = Cell_Corner_Radius;
    
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        
        imageView;
    });
    
    self.panGestureReg = ({
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        
        pan;
    });
}

- (void)updateWithWebModel:(WebModel *)webModel{
    //because of user may operate on webView,so needs update image every time.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!webModel.isImageFromDisk) {
            UIImage *finalImage;
            finalImage = [webModel.image getCornerImageWithFrame:self.imageView.bounds cornerRadius:10 text:webModel.title atPoint:CGPointMake(15, 5)];
            webModel.image = finalImage;
        }
        dispatch_main_async_safe(^{
            [self.imageView setImage:webModel.image];
        })
    });
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan locationInView:self.collectionView];
    
    CGFloat shiftX = point.x - _originTouchX;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.originTouchX = point.x;
            break;
        case UIGestureRecognizerStateChanged:
            self.transform = CGAffineTransformMakeTranslation(shiftX, 0);
            break;
        default:
        {
            if (fabs(shiftX) > self.contentView.width / 4) {
                if (self.closeBlock) {
                    self.closeBlock([self.collectionView indexPathForCell:self]);
                    self.closeBlock = nil;
                }
            }
            else{
                [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.transform = CGAffineTransformIdentity;
                }completion:nil];
            }
            break;
        }
    }
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

#pragma mark - UIGestureRecognizerDelegate Method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
