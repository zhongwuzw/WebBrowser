//
//  ZWDatabaseQueue.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/6.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "FMDatabaseQueue.h"
#import "ZWSQLiteHeader.h"
#import "ZWDatabase.h"

@interface ZWDatabaseQueue : FMDatabaseQueue

- (void)inZWDatabase:(void (^)(ZWDatabase *))block;

@end
