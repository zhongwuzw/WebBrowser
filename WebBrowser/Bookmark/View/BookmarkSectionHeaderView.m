//
//  BookmarkSectionHeaderView.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/26.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkSectionHeaderView.h"

@implementation BookmarkSectionHeaderView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self.diclosureButton setImage:[UIImage imageNamed:@"bookmark-header-button-open"] forState:UIControlStateSelected];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDisclosureBtn:)];
    [self.contentView addGestureRecognizer:tapGesture];
    
    self.contentView.backgroundColor = UIColorFromRGB(0xF7F7F7);
}

- (IBAction)handleDisclosureBtn:(UIButton *)sender{
    [self toggleOpenWithUserAction:YES];
}

- (void)toggleOpenWithUserAction:(BOOL)userAction{
    self.diclosureButton.selected = !self.diclosureButton.selected;
    
    if (userAction) {
        if (self.diclosureButton.selected) {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:isMove:)]) {
                [self.delegate sectionHeaderView:self sectionOpened:self.section isMove:NO];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
    }
}

@end
