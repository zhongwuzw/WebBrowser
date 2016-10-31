//
//  ZWUtility.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/27.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWUtility : NSObject

//Objective-C Runtime Method
void MethodSwizzle(Class c,SEL origSEL,SEL overrideSEL);

@end
