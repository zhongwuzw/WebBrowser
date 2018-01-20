//
//  SettingActivityTableViewCell.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/18.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SettingActivityTableViewCell.h"

@interface SettingActivityTableViewCell ()

@end

@implementation SettingActivityTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.activityIndicatorView setHidesWhenStopped:YES];
}

- (void)setCalculateBlock:(SettingNoParamsBlock)block{
    if (block) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *result = block();
            if ([result isKindOfClass:[NSString class]]) {
                WEAK_REF(self)
                dispatch_main_safe_async(^{
                    STRONG_REF(self_)
                    if (self__) {
                        [self__.activityIndicatorView stopAnimating];
                        self__.rightLabel.text = result;
                    }
                });
            }
        });
    }
}

@end
