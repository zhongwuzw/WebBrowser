//
//  PreferenceHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2017/2/14.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "PreferenceHelper.h"

NSString * const KeyNoImageModeStatus = @"KeyNoImageModeStatus";

@implementation PreferenceHelper

#pragma mark - Setter Method

+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:defaultName];
}

#pragma mark - Getter Method

+ (BOOL)boolForKey:(NSString *)defaultName{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
    return [number boolValue];
}

@end
