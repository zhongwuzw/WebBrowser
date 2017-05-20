//
//  MenuHelper.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "MenuHelper.h"

@implementation MenuHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(MenuHelper)

- (void)setItems{
    NSString *revealPasswordTitle = @"显示";
    UIMenuItem *revealPasswordItem = [[UIMenuItem alloc] initWithTitle:revealPasswordTitle action:@selector(menuHelperReveal)];
    
    NSString *copyTitle = @"拷贝";
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:copyTitle action:@selector(menuHelperCopy)];
    
    NSString *openAndFillTitle = @"打开";
    UIMenuItem *openAndFillItem = [[UIMenuItem alloc] initWithTitle:openAndFillTitle action:@selector(menuHelperOpenAndFill)];
    
    NSString *findInPageTitle = @"页内查找";
    UIMenuItem *findInPageItem = [[UIMenuItem alloc] initWithTitle:findInPageTitle action:@selector(menuHelperFindInPage)];

    [UIMenuController sharedMenuController].menuItems = @[copyItem, revealPasswordItem, openAndFillItem, findInPageItem];

}

@end
