//
//  WebViewBackForwardList.m
//  WebBrowser
//
//  Created by 钟武 on 2017/3/15.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "WebViewBackForwardList.h"
#import "WebViewHistoryItem.h"

@interface WebViewBackForwardList ()

@property (nonatomic, strong) WebViewHistoryItem *currentItem;
@property (nonatomic, copy) NSArray<WebViewHistoryItem *> *backList;
@property (nonatomic, copy) NSArray<WebViewHistoryItem *> *forwardList;

@end

@implementation WebViewBackForwardList

- (instancetype)initWithCurrentItem:(WebViewHistoryItem *)currentItem backList:(NSArray<WebViewHistoryItem *> *)backList forwardList:(NSArray<WebViewHistoryItem *> *)forwardList{
    if (self = [super init]) {
        _currentItem = currentItem;
        _backList = backList;
        _forwardList = forwardList;
    }
    return self;
}

@end
