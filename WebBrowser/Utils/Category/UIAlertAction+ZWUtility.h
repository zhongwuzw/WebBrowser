//
//  UIAlertAction+ZWUtility.h
//  WebBrowser
//
//  Created by 钟武 on 2017/9/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertAction (ZWUtility)

+ (UIAlertAction *)actionCopyLinkWithURL:(NSURL *)linkURL;
+ (UIAlertAction *)actionOpenNewTabWithCompletion:(void (^)(void))completion;
+ (UIAlertAction *)actionDismiss;
+ (UIAlertAction *)actionSettings;

@end
