//
//  KeyboardHelper.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "KeyboardHelper.h"

@implementation KeyboardState

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo{
    if (self = [super init]) {
        _userInfo = userInfo;
        _animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        _animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    }
    
    return self;
}

- (CGFloat)intersectionHeightForView:(UIView *)view{
    NSValue *keyboardFrameValue = _userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    CGRect convertedKeyboardFrame = [view convertRect:keyboardFrame fromView:nil];
    CGRect intersection = CGRectIntersection(convertedKeyboardFrame, view.bounds);
    
    return intersection.size.height;
}

@end

@interface WeakKeyboardDelegate : NSObject

@property (nonatomic, weak) id<KeyboardHelperDelegate> delegate;

@end
@implementation WeakKeyboardDelegate

- (id)initWithDelegate:(id<KeyboardHelperDelegate>) delegate{
    if (self = [super init]) {
        _delegate = delegate;
    }
    
    return self;
}

@end

@interface KeyboardHelper ()

@property (nonatomic, strong) KeyboardState *currentState;
@property (nonatomic, strong) NSMutableArray<WeakKeyboardDelegate *> *delegates;

@end

@implementation KeyboardHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(KeyboardHelper)

- (instancetype)init{
    if (self = [super init]) {
        _delegates = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}

- (void)startObserving{
    [Notifier addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [Notifier addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [Notifier addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)addDelegate:(id<KeyboardHelperDelegate>)delegate{
    foreach(weakDelegate, _delegates) {
        if (!weakDelegate.delegate){
            weakDelegate.delegate = delegate;
            return;
        }
    }
    
    [_delegates addObject:[[WeakKeyboardDelegate alloc] initWithDelegate:delegate]];
}

- (void)removeDelegate:(id<KeyboardHelperDelegate>)delegate{
    for (int i = 0; i < _delegates.count; i++) {
        if (_delegates[i].delegate == delegate) {
            [_delegates removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    _currentState = [[KeyboardState alloc] initWithUserInfo:userInfo];
    
    foreach(weakDelegate, _delegates) {
        if ([weakDelegate.delegate respondsToSelector:@selector(keyboardHelper:keyboardWillShowWithState:)]) {
            [weakDelegate.delegate keyboardHelper:self keyboardWillShowWithState:_currentState];
        }
    }
}

- (void)keyboardDidShow:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    _currentState = [[KeyboardState alloc] initWithUserInfo:userInfo];
    
    foreach(weakDelegate, _delegates) {
        if ([weakDelegate.delegate respondsToSelector:@selector(keyboardHelper:keyboardDidShowWithState:)]) {
            [weakDelegate.delegate keyboardHelper:self keyboardDidShowWithState:_currentState];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    _currentState = [[KeyboardState alloc] initWithUserInfo:userInfo];
    
    foreach(weakDelegate, _delegates) {
        if ([weakDelegate.delegate respondsToSelector:@selector(keyboardHelper:keyboardWillHideWithState:)]) {
            [weakDelegate.delegate keyboardHelper:self keyboardWillHideWithState:_currentState];
        }
    }
}

- (void)dealloc{
    [Notifier removeObserver:self];
}

@end
