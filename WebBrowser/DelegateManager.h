//
//  DelegateManager.h
//  WebBrowser
//
//  Created by 钟武 on 2017/1/1.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DelegateKeyHeader.h"

@class BrowserWebView;

@interface DelegateManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DelegateManager)
- (void)registerDelegate:(id)delegate forKey:(NSString *)key;
- (void)registerDelegate:(id)delegate forKeys:(NSArray<NSString *> *)keys;
- (void)performSelector:(SEL)selector arguments:(NSArray *)arguments key:(NSString *)key;

@end
