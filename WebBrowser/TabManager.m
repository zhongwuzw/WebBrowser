//
//  TabManager.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "TabManager.h"
#import "BrowserWebView.h"
#import "BrowserViewController.h"

#define MULTI_WINDOW_FILE_NAME    @"multiWindowHis.plist"
#define MY_HISTORY_DATA_KEY         @"multiWindowHisData"

#define KEY_WEB_TITLE   @"KEY_WEB_TITLE"
#define KEY_WEB_URL     @"KEY_WEB_URL"
#define KEY_WEB_IMAGE   @"KEY_WEB_IMAGE"
#define KEY_WEB_IMAGE_URL   @"KEY_WEB_IMAGE_URL"

@implementation WebModel

- (NSString *)imageURL{
    if (!_imageURL) {
        return @"";
    }
    return _imageURL;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectOfClass:[NSString class] forKey:KEY_WEB_TITLE];
        _url = [aDecoder decodeObjectOfClass:[NSString class] forKey:KEY_WEB_URL];
//        _image = [aDecoder decodeObjectOfClass:[UIImage class] forKey:KEY_WEB_IMAGE];
        _imageURL = [aDecoder decodeObjectOfClass:[NSString class] forKey:KEY_WEB_IMAGE_URL];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:KEY_WEB_TITLE];
    [aCoder encodeObject:self.url forKey:KEY_WEB_URL];
//    [aCoder encodeObject:self.image forKey:KEY_WEB_IMAGE];
    [aCoder encodeObject:self.imageURL forKey:KEY_WEB_IMAGE_URL];
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

@end

@interface TabManager ()

@property (nonatomic, strong) NSMutableArray<WebModel *> *webModelArray;
@property (nonatomic, copy)   NSString *filePath;
@property (nonatomic, strong) dispatch_queue_t synchQueue;

@end

@implementation TabManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TabManager)

- (instancetype)init{
    if (self = [super init]) {
        _filePath = [DocumentPath stringByAppendingPathComponent:MULTI_WINDOW_FILE_NAME];
        NSString *queueName = [NSString stringWithFormat:@"com.zhongwu.TabManager-%@", [[NSUUID UUID] UUIDString]];
        _synchQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        _webModelArray = [NSMutableArray arrayWithCapacity:4];
        [self loadWebModelArray];
    }
    
    return self;
}

- (void)loadWebModelArray{
    dispatch_async(self.synchQueue, ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
                NSData *data = [NSData dataWithContentsOfFile:_filePath options:NSDataReadingUncached error:nil];
                if (data) {
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                    NSArray<WebModel *> *array = [unarchiver decodeObjectForKey:MY_HISTORY_DATA_KEY];
                    [unarchiver finishDecoding];
                    
                    if (array && [array isKindOfClass:[NSArray<WebModel *> class]] && array.count > 0) {
                        [_webModelArray addObjectsFromArray:array];
                    }
                    else
                        [self setDefaultWebArray];
                }
                else
                    [self setDefaultWebArray];
            }
            else
                [self setDefaultWebArray];
        });
    });
}

- (void)saveWebModelData{
    dispatch_async(self.synchQueue, ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [archiver encodeObject:_webModelArray forKey:MY_HISTORY_DATA_KEY];
            [archiver finishEncoding];
            
            [data writeToFile:_filePath atomically:YES];
        });
    });
}

- (void)setDefaultWebArray{
    [_webModelArray removeAllObjects];
    [_webModelArray addObject:[self getDefaultWebModel]];
}

- (WebModel *)getDefaultWebModel{
    WebModel *webModel = [WebModel new];
    webModel.title = @"百度一下";
    webModel.url = @"https://m.baidu.com/";
    
    return webModel;
}

- (void)setMultiWebViewOperationBlockWith:(MultiWebViewOperationBlock)block{
    dispatch_async(self.synchQueue, ^{
        dispatch_main_sync_safe(^{
            if (block) {
                block([_webModelArray copy]);
            }
        })
    });
}

# warning 每次赋值后都需要对两个数组做判空处理，避免数组出现为空的情况

- (void)setCurWebViewOperationBlockWith:(CurWebViewOperationBlock)block{
    dispatch_async(self.synchQueue, ^{
        dispatch_main_sync_safe(^{
            BrowserWebView *browserWebView;
            WebModel *curModel = [_webModelArray lastObject];
            if (!curModel.webView) {
                browserWebView = [BrowserWebView new];
                browserWebView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_HEIGHT, 0, 0, 0);
                _webModelArray[_webModelArray.count - 1].webView = browserWebView;
            }
            else
                browserWebView = curModel.webView;
            
            browserWebView.scrollView.delegate = [BrowserViewController sharedInstance];
            if (block) {
                block([_webModelArray lastObject], browserWebView);
            }
        })
    });
}

- (void)setWebModelArray:(NSArray<WebModel *> *)webArray{
    NSArray *copyArray = [webArray copy];
    
    dispatch_async(self.synchQueue, ^{
        if (!copyArray.count) {
            [self setDefaultWebArray];
        }
        else
        {
            [self.webModelArray removeAllObjects];
            [self.webModelArray addObjectsFromArray:copyArray];
        }
    });
}

@end
