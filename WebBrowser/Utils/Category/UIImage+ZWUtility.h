//
//  UIImage+ZWUtility.h
//  WebBrowser
//
//  Created by 钟武 on 2017/1/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZWUtility)

- (UIImage *)getCornerImageWithFrame:(CGRect)rect cornerRadius:(CGFloat)cornerRadius text:(NSString *)text atPoint:(CGPoint)point;

@end
