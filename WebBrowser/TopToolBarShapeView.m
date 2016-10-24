//
//  TopToolBarShapeView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/12.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "TopToolBarShapeView.h"

@interface TopToolBarShapeView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation TopToolBarShapeView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    
    return self;
}

- (void)initializeView{
    self.label = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label;
    });
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer
{
    return (CAShapeLayer *)self.layer;
}

- (void)setTopURLOrTitle:(NSString *)urlOrTitle{
    [self.label setText:urlOrTitle];
}

@end
