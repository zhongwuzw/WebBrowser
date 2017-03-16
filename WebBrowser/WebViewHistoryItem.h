//
//  WebViewHistoryItem.h
//  WebBrowser
//
//  Created by 钟武 on 2017/3/15.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebViewHistoryItem : NSObject

@property (nonatomic, copy, readonly) NSString *URLString;
@property (nonatomic, copy, readonly) NSString *title;

- (instancetype)initWithURLString:(NSString *)URLString title:(NSString *)title;

@end
