//
//  BrowserTopToolBar.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/12.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserTopToolBar.h"
#import "TopToolBarShapeView.h"
#import "BrowserHeader.h"

#define SHAPE_VIEW_WIDTH 30
#define SHAPE_VIEW_HEIGHT 44
#define ShAPE_VIEW_Y_OFFSET 5

@interface BrowserTopToolBar ()
@property (nonatomic, strong) TopToolBarShapeView *shapeView;

@end

@implementation BrowserTopToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView{
    self.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    self.shapeView = ({
        TopToolBarShapeView *shapeView = [[TopToolBarShapeView alloc] initWithFrame:CGRectMake(0, 0, self.width - SHAPE_VIEW_WIDTH, self.height - SHAPE_VIEW_HEIGHT)];
        shapeView.center = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + ShAPE_VIEW_Y_OFFSET};
        shapeView.shapeLayer.lineWidth = 2;
        shapeView.shapeLayer.fillColor = UIColorFromRGB(0xE6E6E7).CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeView.bounds cornerRadius:6];
        [path stroke];
        shapeView.shapeLayer.path = path.CGPath;
        
        [self addSubview:shapeView];
        shapeView;
    });
    
}

- (void)setFrame:(CGRect)frame{
    if (frame.size.height != self.height) {
        CGFloat shapeViewHeight = fabs(frame.size.height * (TOP_TOOL_BAR_HEIGHT - SHAPE_VIEW_HEIGHT) / TOP_TOOL_BAR_HEIGHT);
        self.shapeView.center = (CGPoint){frame.size.width/2, frame.size.height/2 + ShAPE_VIEW_Y_OFFSET};
        
        self.shapeView.transform = CGAffineTransformMakeScale(shapeViewHeight / (TOP_TOOL_BAR_HEIGHT - SHAPE_VIEW_HEIGHT), shapeViewHeight / (TOP_TOOL_BAR_HEIGHT - SHAPE_VIEW_HEIGHT));
    }
    
    [super setFrame:frame];
}

- (void)setTopURLOrTitle:(NSString *)urlOrTitle{
    [self.shapeView setTopURLOrTitle:urlOrTitle];
}

@end
