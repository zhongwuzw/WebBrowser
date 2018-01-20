//
//  MacroMethod.h
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#ifndef MacroMethod_h
#define MacroMethod_h

#import <objc/runtime.h>

#pragma mark - Notification

#define Notifier  [NSNotificationCenter defaultCenter]

#pragma mark Color

//颜色宏定义
#define ColorRedGreenBlue(r, g, b)				[UIColor colorWithRed : (r) / 255.0f green : (g) / 255.0f blue : (b) / 255.0f alpha : 1.0f]
#define ColorRedGreenBlueWithAlpha(r, g, b, a)	[UIColor colorWithRed : (r) / 255.0f green : (g) / 255.0f blue : (b) / 255.0f alpha : a]

#define UIColorFromRGB(rgbValue)				[UIColor colorWithRed : ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0f green : ((float)((rgbValue & 0xFF00) >> 8)) / 255.0f blue : ((float)(rgbValue & 0xFF)) / 255.0f alpha : 1.0f]
#define UIColorFromRGBAndAlpha(rgbValue,a)				[UIColor colorWithRed : ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0f green : ((float)((rgbValue & 0xFF00) >> 8)) / 255.0f blue : ((float)(rgbValue & 0xFF)) / 255.0f alpha : a]

#pragma mark - WEAK、STRONG

//weak、strong创建
#define WEAK_REF(self) \
__block __weak typeof(self) self##_ = self; (void) self##_;

#define STRONG_REF(self) \
__block __strong typeof(self) self##_ = self; (void) self##_;

#pragma mark - SharedInstance

#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(__CLASSNAME__)	\
    \
    + (__CLASSNAME__*) sharedInstance;


#define SYNTHESIZE_SINGLETON_FOR_CLASS(__CLASSNAME__)	\
    + (__CLASSNAME__ *)sharedInstance\
    {\
        static __CLASSNAME__ *shared##className = nil;\
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ \
            shared##className = [[super allocWithZone:NULL] init]; \
    }); \
    return shared##className; \
}\
+ (id)allocWithZone:(NSZone*)zone {\
    return [self sharedInstance];\
}\
- (id)copyWithZone:(NSZone *)zone {\
    return self;\
}

#pragma mark - Safe Main Queue

//安全main queue 执行
#define dispatch_main_safe_sync(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_safe_async(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#pragma mark - PATH

#define HomePath NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]
#define DocumentPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define CachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define TempPath NSTemporaryDirectory()

#pragma mark - Convienence

#define IsCurrentWebView(webView)  [[TabManager sharedInstance] isCurrentWebView:webView]

#define BrowserVC  [BrowserViewController sharedInstance]

#endif /* MacroMethod_h */
