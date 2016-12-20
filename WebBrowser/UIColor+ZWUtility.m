//
//  UIColor+ZWUtility.m
//  iOSSampleCode
//
//  Created by 钟武 on 16/7/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "UIColor+ZWUtility.h"

@implementation UIColor (ZWUtility)

+ (UIColor *)randomColor
{
    CGFloat hue = (arc4random() % 100) / 100;
    CGFloat saturation = (arc4random() % 100) / 100;
    CGFloat brightness = (arc4random() % 100) / 100;
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
}

@end
