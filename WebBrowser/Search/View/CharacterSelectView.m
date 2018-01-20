//
//  CharacterSelectView.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/5.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "CharacterSelectView.h"

@implementation CharacterSelectView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    self.value = 0.5f;
    self.minimumTrackTintColor = UIColorFromRGB(0xE4E6E8);
    self.maximumTrackTintColor = UIColorFromRGB(0xE4E6E8);
}

- (CGRect)trackRectForBounds:(CGRect)bounds{
    return CGRectMake(bounds.origin.x, 8, bounds.size.width, 14);
}

@end
