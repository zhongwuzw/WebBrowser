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
    NSString *findInPageTitle = @"页内查找";
    UIMenuItem *findInPageItem = [[UIMenuItem alloc] initWithTitle:findInPageTitle action:@selector(menuHelperFindInPage)];
    
    NSString *findInBaidu = @"百度搜索";
    UIMenuItem *findInBaiduItem = [[UIMenuItem alloc] initWithTitle:findInBaidu action:@selector(menuHelperFindInBaidu)];

    [UIMenuController sharedMenuController].menuItems = @[findInPageItem, findInBaiduItem];

}

@end
