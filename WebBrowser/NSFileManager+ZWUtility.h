//
//  NSFileManager+ZWUtility.h
//  WebBrowser
//
//  Created by 钟武 on 2017/1/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (ZWUtility)

- (long long)getAllocatedSizeOfDirectoryAtURL:(NSURL *)directoryURL error:(NSError **)error;

- (long long)getAllocatedSizeOfDirectoryAtURLS:(NSArray<NSURL *> *)directoryURLs error:(NSError **)error;

@end
