//
//  UIImage+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "UIImage+ZWUtility.h"

#define UIImage_Text_Height 20

@implementation UIImage (ZWUtility)

- (UIImage *)getCornerImageWithFrame:(CGRect)rect cornerRadius:(CGFloat)cornerRadius text:(NSString *)text atPoint:(CGPoint)point{
    UIImage *image;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    CGRect imageRect = rect;
    imageRect.origin.y = UIImage_Text_Height;
    imageRect.size.height -= UIImage_Text_Height;
    [self drawInRect:imageRect];
    
//    CGRect closeRect = CGRectMake(rect.size.width - Card_Cell_Close_Width - 10, 0, Card_Cell_Close_Width, Card_Cell_Close_Height);
//    DDLogDebug(@"close button x is: %f",closeRect.origin.x);
//    [[UIImage imageNamed:@"card-delete"] drawInRect:closeRect];
    
    CGRect textRect = CGRectMake(point.x, point.y, rect.size.width, UIImage_Text_Height);
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    [text drawInRect:textRect withAttributes:dic
     ];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
