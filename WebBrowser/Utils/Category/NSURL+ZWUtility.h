//
//  NSURL+ZWUtility.h
//  WebBrowser
//
//  Created by 钟武 on 2017/2/18.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (ZWUtility)

- (BOOL)isErrorPageURL;
- (NSURL *)originalURLFromErrorURL;
- (BOOL)isLocal;

@end
