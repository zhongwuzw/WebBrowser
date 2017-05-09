//
//  BookmarkTableViewCell.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/26.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkTableViewCell.h"

@implementation BookmarkTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    self.showsReorderControl = editing;
}

@end
