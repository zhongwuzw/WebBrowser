//
//  PreferenceHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2017/2/14.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "PreferenceHelper.h"

NSString * const KeyNoImageModeStatus = @"KeyNoImageModeStatus";
NSString * const KeyPasteboardURL = @"KeyPasteboardURL";

@implementation PreferenceHelper

#pragma mark - Setter Method

+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:defaultName];
}

+ (void)setURL:(NSURL *)url forKey:(NSString *)defaultName{
    [[NSUserDefaults standardUserDefaults] setURL:url forKey:defaultName];
}

#pragma mark - Getter Method

+ (BOOL)boolForKey:(NSString *)defaultName{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
    return [number boolValue];
}

+ (NSURL *)URLForKey:(NSString *)defaultName{
    return [[NSUserDefaults standardUserDefaults] URLForKey:defaultName];
}

@end
