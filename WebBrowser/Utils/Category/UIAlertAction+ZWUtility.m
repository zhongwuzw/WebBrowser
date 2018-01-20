//
//  UIAlertAction+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/9/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "UIAlertAction+ZWUtility.h"
#import "BrowserViewController.h"

static NSString *const CancelString = @"取消";

@implementation UIAlertAction (ZWUtility)

+ (UIAlertAction *)actionCopyLinkWithURL:(NSURL *)linkURL{
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"拷贝链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.URL = linkURL;
        [[BrowserVC navigationController].view showHUDAtBottomWithMessage:@"拷贝成功"];
    }];
    return copyAction;
}

+ (UIAlertAction *)actionOpenNewTabWithCompletion:(void (^)(void))completion{
    UIAlertAction  *openNewTabAction = [UIAlertAction actionWithTitle:@"在新窗口打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (completion) {
            completion();
        }
    }];
    return openNewTabAction;
}

+ (UIAlertAction *)actionDismiss{
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:CancelString style:UIAlertActionStyleCancel handler:nil];
    return dismissAction;
}

+ (UIAlertAction *)actionSettings{
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"打开设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    return settingsAction;
}

@end
