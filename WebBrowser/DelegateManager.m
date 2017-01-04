//
//  DelegateManager.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/1.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "DelegateManager.h"

@interface DelegateManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSPointerArray *> *delegateDic;

@end

@implementation DelegateManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DelegateManager)

- (NSMutableDictionary *)delegateDic{
    if (!_delegateDic) {
        _delegateDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _delegateDic;
}

- (void)registerDelegate:(id)delegate forKey:(NSString *)key{
    if (!delegate || !key) {
        return;
    }
    
    NSPointerArray *array = [self.delegateDic objectForKey:key];
    if (!array) {
        array = [NSPointerArray weakObjectsPointerArray];
        [self.delegateDic setObject:array forKey:key];
    }
    [array addPointer:(__bridge void *)delegate];
}

- (void)callInvocation:(NSInvocation *)anInvocation withKey:(NSString *)key{
    if (!key || !anInvocation) {
        return;
    }
    NSPointerArray *array = [self.delegateDic objectForKey:key];
    
    [array compact];
    if ([array count] == 0) {
        return;
    }
    [[array allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if ([obj respondsToSelector:anInvocation.selector]) {
            [anInvocation setTarget:obj];
            [anInvocation invoke];
        }
    }];
}

@end
