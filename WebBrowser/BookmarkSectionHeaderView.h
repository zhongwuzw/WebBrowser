//
//  BookmarkSectionHeaderView.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/26.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SectionHeaderViewDelegate;

@interface BookmarkSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *diclosureButton;
@property (weak, nonatomic) id<SectionHeaderViewDelegate> delegate;
@property (assign, nonatomic) NSInteger section;

- (void)toggleOpenWithUserAction:(BOOL)userAction;

@end

#pragma mark -

@protocol SectionHeaderViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(BookmarkSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section isMove:(BOOL)isMove;
- (void)sectionHeaderView:(BookmarkSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;

@end
