//
//  MenuHelper.h
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuHelperInterface <NSObject>

- (void)menuHelperCopy:(NSNotification *)sender;
- (void)menuHelperOpenAndFill:(NSNotification *)sender;
- (void)menuHelperReveal:(NSNotification *)sender;
- (void)menuHelperSecure:(NSNotification *)sender;
- (void)menuHelperFindInPage:(NSNotification *)sender;

@end

@interface MenuHelper : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MenuHelper)
- (void)setItems;

@end
