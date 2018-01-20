//
//  SessionData.h
//  WebBrowser
//
//  Created by 钟武 on 2017/3/15.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionData : NSObject

@property (nonatomic, readonly) NSDictionary *jsonDictionary;

- (instancetype)initWithCurrentPage:(NSInteger)currentPage urls:(NSArray <NSString *> *)urls;

@end
