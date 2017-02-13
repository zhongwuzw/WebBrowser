//
//  AppDelegate.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AppDelegate.h"
#import "KeyboardHelper.h"
#import "MenuHelper.h"
#import "BrowserViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)setAudioPlayInBackgroundMode{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    DDLogDebug(@"Home Path : %@", HomePath);

    BrowserViewController *browserViewController = [BrowserViewController new];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:browserViewController];
    navigationController.navigationBarHidden = YES;
    navigationController.view.backgroundColor = [UIColor whiteColor];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    //解决UIWebView首次加载页面时间过长问题
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : @"    Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1"}];
    
    [self setAudioPlayInBackgroundMode];
    
    return YES;
}

@end
