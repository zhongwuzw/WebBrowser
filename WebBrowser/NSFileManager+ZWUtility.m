//
//  NSFileManager+ZWUtility.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "NSFileManager+ZWUtility.h"

@implementation NSFileManager (ZWUtility)

- (long long)getAllocatedSizeOfDirectoryAtURLS:(NSArray<NSURL *> *)directoryURLs error:(NSError * _Nullable __autoreleasing *)error{
    __block unsigned long long accumulatedSize = 0;
    
    __block BOOL isError = NO;
    [directoryURLs enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop){
        long long size = 0;
        if ((size = [self getAllocatedSizeOfDirectoryAtURL:url error:error]) != -1) {
            accumulatedSize += size;
        }
        else{
            isError = YES;
            *stop = YES;
        }
    }];
    
    if (isError) {
        return -1;
    }
    
    return accumulatedSize;
}

- (long long)getAllocatedSizeOfDirectoryAtURL:(NSURL *)directoryURL error:(NSError * _Nullable __autoreleasing *)error{
    unsigned long long accumulatedSize = 0;
    
    NSArray *prefetchedProperties = @[
                                      NSURLIsRegularFileKey,
                                      NSURLFileAllocatedSizeKey,
                                      NSURLTotalFileAllocatedSizeKey,
                                      ];
    
    __block BOOL errorDidOccur = NO;
    BOOL (^errorHandler)(NSURL *, NSError *) = ^(NSURL *url, NSError *localError) {
        if (error != NULL)
            *error = localError;
        errorDidOccur = YES;
        return NO;
    };
    
    NSDirectoryEnumerator *enumerator = [self enumeratorAtURL:directoryURL includingPropertiesForKeys:prefetchedProperties options:0 errorHandler:errorHandler];
    
    foreach(contentItemURL, enumerator) {
        if (errorDidOccur)
            return -1;
        
        NSNumber *isRegularFile;
        if (! [contentItemURL getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:error])
            return -1;
        if (! [isRegularFile boolValue])
            continue;
        
        NSNumber *fileSize;
        if (! [contentItemURL getResourceValue:&fileSize forKey:NSURLTotalFileAllocatedSizeKey error:error])
            return -1;
        
        if (fileSize == nil) {
            if (! [contentItemURL getResourceValue:&fileSize forKey:NSURLFileAllocatedSizeKey error:error])
                return -1;
        }
        
        accumulatedSize += [fileSize unsignedLongLongValue];
    }
    
    if (errorDidOccur)
        return -1;
    
    return accumulatedSize;
}

@end
