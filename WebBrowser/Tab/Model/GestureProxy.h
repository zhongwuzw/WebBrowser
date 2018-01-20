//
//  GestureProxy.h
//  WebBrowser
//
//  Created by 钟武 on 2017/9/20.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GestureProxy : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGPoint point;

- (instancetype)initWithCGPoint:(CGPoint)point;

@end
