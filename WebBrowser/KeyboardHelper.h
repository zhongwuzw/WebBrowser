//
//  KeyboardHelper.h
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyboardHelperDelegate;

@interface KeyboardHelper : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(KeyboardHelper)
- (void)startObserving;
- (void)addDelegate:(id<KeyboardHelperDelegate>)delegate;

@end
