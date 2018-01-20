//
//  WebViewBackForwardList.h
//  WebBrowser
//
//  Created by 钟武 on 2017/3/15.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewHistoryItem.h"

@interface WebViewBackForwardList : NSObject

@property (nonatomic, readonly) WebViewHistoryItem *currentItem;
@property (nonatomic, readonly) NSArray<WebViewHistoryItem *> *backList;
@property (nonatomic, readonly) NSArray<WebViewHistoryItem *> *forwardList;

- (instancetype)initWithCurrentItem:(WebViewHistoryItem *)currentItem backList:(NSArray<WebViewHistoryItem *> *)backList forwardList:(NSArray<WebViewHistoryItem *> *)forwardList;

@end
