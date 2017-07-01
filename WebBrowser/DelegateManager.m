//
//  DelegateManager.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/1.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "DelegateManager.h"

NSString *const DelegateManagerWebView = @"WebViewDelegate";
NSString *const DelegateManagerBrowserContainerLoadURL = @"DelegateManagerBrowserContainerLoadURL";
NSString *const DelegateManagerFindInPageBarDelegate = @"DelegateManagerFindInPageBarDelegate";

// Arguments 0 and 1 are self and _cmd always
const unsigned int kNumberOfImplicitArgs = 2;

@interface DelegateManager () <BrowserWebViewDelegate, BrowserContainerLoadURLDelegate, FindInPageBarDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSPointerArray *> *delegateDic;
@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;

@end

@implementation DelegateManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DelegateManager)

- (instancetype)init{
    if (self = [super init]) {
        NSString *queueName = [NSString stringWithFormat:@"com.zhongwu.delegateManager-%@", [[NSUUID UUID] UUIDString]];
        _synchronizationQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSMutableDictionary *)delegateDic{
    if (!_delegateDic) {
        _delegateDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _delegateDic;
}

- (void)registerDelegate:(id)delegate forKeys:(NSArray<NSString *> *)keys{
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop){
        [self registerDelegate:delegate forKey:key];
    }];
}

- (void)registerDelegate:(id)delegate forKey:(NSString *)key{
    if (!delegate || !key) {
        return;
    }
    
    dispatch_async(self.synchronizationQueue, ^{
        NSPointerArray *array = [self.delegateDic objectForKey:key];
        if (!array) {
            array = [NSPointerArray weakObjectsPointerArray];
            [self.delegateDic setObject:array forKey:key];
        }
        [array addPointer:(__bridge void *)delegate];
    });
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
            dispatch_main_safe_sync(^{
                [anInvocation invoke];
            })
        }
    }];
}

#pragma mark - Method Calling

- (void)performSelector:(SEL)selector arguments:(NSArray *)arguments key:(NSString *)key{
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    
    if (!methodSignature || ![arguments isKindOfClass:[NSArray class]] || !key) {
        return;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    [invocation retainArguments];
    
    NSUInteger numberOfArguments = [methodSignature numberOfArguments];
    
    if (arguments.count != numberOfArguments - kNumberOfImplicitArgs) {
        return;
    }
    
    for (NSUInteger argumentIndex = kNumberOfImplicitArgs; argumentIndex < numberOfArguments; argumentIndex++) {
        NSUInteger argumentsArrayIndex = argumentIndex - kNumberOfImplicitArgs;
        id argumentObject = [arguments count] > argumentsArrayIndex ? [arguments objectAtIndex:argumentsArrayIndex] : nil;
        
        if (argumentObject && ![argumentObject isKindOfClass:[NSNull class]]) {
            const char *typeEncodingCString = [methodSignature getArgumentTypeAtIndex:argumentIndex];
            if (typeEncodingCString[0] == @encode(id)[0] || typeEncodingCString[0] == @encode(Class)[0] || [self isTollFreeBridgedValue:argumentObject forCFType:typeEncodingCString]) {
                [invocation setArgument:&argumentObject atIndex:argumentIndex];
            } else if (strcmp(typeEncodingCString, @encode(CGColorRef)) == 0 && [argumentObject isKindOfClass:[UIColor class]]) {
                CGColorRef colorRef = [argumentObject CGColor];
                [invocation setArgument:&colorRef atIndex:argumentIndex];
            } else if ([argumentObject isKindOfClass:[NSValue class]]){
                NSValue *argumentValue = (NSValue *)argumentObject;
                
                if (strcmp([argumentValue objCType], typeEncodingCString) != 0) {
                    return;
                }
                
                NSUInteger bufferSize = 0;
                @try {
                    NSGetSizeAndAlignment(typeEncodingCString, &bufferSize, NULL);
                } @catch (NSException *exception) { }
                
                if (bufferSize > 0) {
                    void *buffer = calloc(bufferSize, 1);
                    [argumentValue getValue:buffer];
                    [invocation setArgument:buffer atIndex:argumentIndex];
                    free(buffer);
                }
            }
        }
    }
    
    [self callInvocation:invocation withKey:key];
}

- (BOOL)isTollFreeBridgedValue:(id)value forCFType:(const char *)typeEncoding
{
    // See https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/Toll-FreeBridgin/Toll-FreeBridgin.html
#define CASE(cftype, foundationClass) \
if(strcmp(typeEncoding, @encode(cftype)) == 0) { \
return [value isKindOfClass:[foundationClass class]]; \
}
    
    CASE(CFArrayRef, NSArray);
    CASE(CFAttributedStringRef, NSAttributedString);
    CASE(CFCalendarRef, NSCalendar);
    CASE(CFCharacterSetRef, NSCharacterSet);
    CASE(CFDataRef, NSData);
    CASE(CFDateRef, NSDate);
    CASE(CFDictionaryRef, NSDictionary);
    CASE(CFErrorRef, NSError);
    CASE(CFLocaleRef, NSLocale);
    CASE(CFMutableArrayRef, NSMutableArray);
    CASE(CFMutableAttributedStringRef, NSMutableAttributedString);
    CASE(CFMutableCharacterSetRef, NSMutableCharacterSet);
    CASE(CFMutableDataRef, NSMutableData);
    CASE(CFMutableDictionaryRef, NSMutableDictionary);
    CASE(CFMutableSetRef, NSMutableSet);
    CASE(CFMutableStringRef, NSMutableString);
    CASE(CFNumberRef, NSNumber);
    CASE(CFReadStreamRef, NSInputStream);
    CASE(CFRunLoopTimerRef, NSTimer);
    CASE(CFSetRef, NSSet);
    CASE(CFStringRef, NSString);
    CASE(CFTimeZoneRef, NSTimeZone);
    CASE(CFURLRef, NSURL);
    CASE(CFWriteStreamRef, NSOutputStream);
    
#undef CASE
    
    return NO;
}

@end
