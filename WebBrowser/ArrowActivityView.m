//
//  ArrowActivityView.m
//  WebBrowser
//
//  Created by 钟武 on 2017/9/12.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ArrowActivityView.h"

static CGFloat const kArrowHorizonalMargin = 8.f;
static CGFloat const kArrowXOffset = 6.f;
static CGFloat const kArrowYOffset = 8.f;

@interface ArrowActivityView ()

@property (nonatomic, assign) ArrowActivityKinds kind;
@property (nonatomic, assign) ArrowActivityKinds lastKind;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) UIColor *onArrowColor;
@property (nonatomic, strong) UIColor *onCircleColor;
@property (nonatomic, strong) UIColor *offArrowColor;
@property (nonatomic, assign) CGFloat arrowLineWidth;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL firstRender;

@end

@implementation ArrowActivityView

- (instancetype)initWithFrame:(CGRect)frame kind:(ArrowActivityKinds)kind{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _onArrowColor = UIColorFromRGB(0x5A5A5A);
    _onCircleColor = [UIColor whiteColor];
    _offArrowColor = [UIColor whiteColor];
    _arrowLineWidth = 2.0f;
    _animationDuration = 0.5f;
    _firstRender = YES;
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setKind:(ArrowActivityKinds)kind{
    _lastKind = _kind;
    _kind = kind;
    [self reload];
}

- (BOOL)isOn{
    return _on;
}

- (void)setOn:(BOOL)on{
    BOOL lastOn = _on;
    _on = on;
    if (!_firstRender && lastOn == on && _lastKind == _kind ) {
        return;
    }

    if (on) {
        [self drawOnCircle];
    }
    else{
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
    }
    [self drawOnOrOffArrow:on];
    _firstRender = NO;
}

- (void)reload{
    [self.arrowLayer removeFromSuperlayer];
    self.arrowLayer = nil;
    
    [self.circleLayer removeFromSuperlayer];
    self.circleLayer = nil;
    
    [self setOn:_on];
}

- (void)drawOnCircle{
    [self.circleLayer removeFromSuperlayer];
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.frame = self.bounds;
    self.circleLayer.path = [self pathForCircle].CGPath;
    self.circleLayer.lineWidth = self.arrowLineWidth;
    self.circleLayer.fillColor = self.onCircleColor.CGColor;
    self.circleLayer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    self.circleLayer.shouldRasterize = YES;
    [self.layer addSublayer:self.circleLayer];
}

- (void)drawOnOrOffArrow:(BOOL)isOn{
    [self.arrowLayer removeFromSuperlayer];
    self.arrowLayer = [CAShapeLayer layer];
    self.arrowLayer.frame = self.bounds;
    self.arrowLayer.path = [self pathForArrow].CGPath;
    self.arrowLayer.lineWidth = self.arrowLineWidth;
    self.arrowLayer.strokeColor = isOn ? self.onArrowColor.CGColor : self.offArrowColor.CGColor;
    self.arrowLayer.lineCap = kCALineCapRound;
    self.arrowLayer.lineJoin = kCALineJoinRound;
    self.arrowLayer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    self.arrowLayer.shouldRasterize = YES;
    [self.layer addSublayer:self.arrowLayer];
}

- (UIBezierPath *)pathForCircle{
    CGFloat radius = self.width / 2.0 - self.arrowLineWidth / 2.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width / 2.0f, self.height / 2.0f) radius:radius startAngle:-M_PI / 4 endAngle:2 * M_PI - M_PI / 4 clockwise:YES];
    return path;
}

- (UIBezierPath *)pathForArrow{
    UIBezierPath *path = [UIBezierPath bezierPath];
    switch (self.kind) {
        case ArrowActivityKindLeft:
            [path moveToPoint:CGPointMake(kArrowHorizonalMargin, self.height / 2.0f)];
            [path addLineToPoint:CGPointMake(self.width - kArrowHorizonalMargin, self.height / 2.0f)];
            [path moveToPoint:CGPointMake(kArrowHorizonalMargin, self.height / 2.0f)];
            [path addLineToPoint:CGPointMake(kArrowHorizonalMargin + kArrowXOffset, self.height / 2.0f - kArrowYOffset)];
            [path moveToPoint:CGPointMake(kArrowHorizonalMargin, self.height / 2.0f)];
            [path addLineToPoint:CGPointMake(kArrowHorizonalMargin + kArrowXOffset, self.height / 2.0f + kArrowYOffset)];
            break;
        case ArrowActivityKindRight:
            [path moveToPoint:CGPointMake(self.width - kArrowHorizonalMargin, self.height / 2.0f)];
            [path addLineToPoint:CGPointMake(kArrowHorizonalMargin, self.height / 2.0f)];
            [path moveToPoint:CGPointMake(self.width - kArrowHorizonalMargin, self.height / 2.0f)];
            [path addLineToPoint:CGPointMake(self.width - kArrowHorizonalMargin - kArrowXOffset, self.height / 2.0f - kArrowYOffset)];
            [path moveToPoint:CGPointMake(self.width - kArrowHorizonalMargin, self.height / 2.0f)];
            [path addLineToPoint:CGPointMake(self.width - kArrowHorizonalMargin - kArrowXOffset, self.height / 2.0f + kArrowYOffset)];
            break;
        default:
            break;
    }
    
    return path;
}

@end
