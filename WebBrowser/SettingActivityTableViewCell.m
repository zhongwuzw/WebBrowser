//
//  SettingActivityTableViewCell.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/18.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SettingActivityTableViewCell.h"

@interface SettingActivityTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation SettingActivityTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

@end
