//
//  GestureProxy.m
//  WebBrowser
//
//  Created by 钟武 on 2017/9/20.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "GestureProxy.h"

@implementation GestureProxy

- (instancetype)initWithCGPoint:(CGPoint)point{
    if (self = [super init]) {
        _point = point;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return  NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    UIView *view = gestureRecognizer.view;
    CGPoint location = [gestureRecognizer locationInView:view];
    
    if (CGRectContainsPoint(CGRectInset(view.frame, _point.x, _point.y), location)) {
        return NO;
    }
    
    return YES;
}

@end
