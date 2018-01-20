//
//  ArrowActivityView.h
//  WebBrowser
//
//  Created by 钟武 on 2017/9/12.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ArrowActivityKinds) {
    ArrowActivityKindLeft,
    ArrowActivityKindRight
};

@interface ArrowActivityView : UIView

- (instancetype)initWithFrame:(CGRect)frame kind:(ArrowActivityKinds)kind;
- (void)setOn:(BOOL)on;
- (BOOL)isOn;
- (void)setKind:(ArrowActivityKinds)kind;

@end
