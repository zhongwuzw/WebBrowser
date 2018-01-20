//
//  ZWSQLiteManager.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/6.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ZWSQLiteManager.h"

@interface ZWSQLiteManager ()

@property (nonatomic, strong) dispatch_queue_t synchQueue;
@property (nonatomic, strong) ZWDatabaseQueue *databaseQueue;

@end

@implementation ZWSQLiteManager

- (instancetype)initWithPath:(NSString *)inPath{
    if (self = [super init]) {
        _databaseQueue = [ZWDatabaseQueue databaseQueueWithPath:inPath];
        NSString *queueName = [NSString stringWithFormat:@"com.zhongwu.SQLite-%@", [[NSUUID UUID] UUIDString]];
        _synchQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        [self databaseManagerDidCreated];
    }
    return self;
}

//Stub
- (void)databaseManagerDidCreated{}

- (void)dealloc{
    [self.databaseQueue close];
}

@end
