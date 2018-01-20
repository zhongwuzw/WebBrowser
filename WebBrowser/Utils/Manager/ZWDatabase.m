//
//  ZWDatabase.m
//  WebBrowser
//
//  Created by 钟武 on 2017/4/6.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ZWDatabase.h"

@implementation ZWDatabase

- (FMResultSet *)executeZWQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments{
    FMResultSet *result = [super executeQuery:sql withArgumentsInArray:arguments];
    return result;
}

- (BOOL)executeZWUpdate:(NSString *)sql withArgumentsInArray:(NSArray *)arguments{
    return [super executeUpdate:sql withArgumentsInArray:arguments];
}

- (BOOL)executeZWUpdate:(NSString *)sql{
    return [super executeUpdate:sql];
}

- (BOOL)executeZWStatements:(NSString *)sql{
    return [super executeStatements:sql];
}

@end
