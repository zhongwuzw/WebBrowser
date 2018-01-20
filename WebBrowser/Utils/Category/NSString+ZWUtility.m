//
//  NSString+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

static NSString * const kURLRegEx = @"((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";

#import "NSString+ZWUtility.h"

@implementation NSString (ZWUtility)

- (BOOL)isValidURL{
    NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",kURLRegEx];
    return [urlPredic evaluateWithObject:self];
}

- (BOOL)isLocal{
    NSURL *url = [NSURL URLWithString:self];
    return [url.host.lowercaseString isEqualToString:@"localhost"] || [url.host isEqualToString:@"127.0.0.1"];
}

- (NSString *)ellipsizeWithMaxLength:(NSInteger)maxLength{
    if (maxLength >= 2 && self.length > maxLength) {
        NSInteger index1 = (maxLength + 1) / 2;
        NSInteger index2 = self.length - maxLength / 2;
        
        NSString *index1Str = [self substringToIndex:index1];
        NSString *index2Str = [self substringFromIndex:index2];
        
        return [NSString stringWithFormat:@"%@…\u2060%@",index1Str,index2Str];
    }
    return self;
}

- (NSDictionary *)getWebViewJSONDicWithPrefix:(NSString *)prefix{
    NSDictionary *jsonDic = nil;
    if ([self hasPrefix:prefix]) {
        NSString *jsonStr = [self substringFromIndex:prefix.length];
        
        jsonStr = [jsonStr stringByRemovingPercentEncoding];
        if (jsonStr) {
            jsonDic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
            if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                return jsonDic;
            }
        }
    }
    return jsonDic;
}

@end
