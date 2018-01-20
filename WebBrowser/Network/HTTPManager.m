//
//  HTTPManager.m
//  ZhihuDaily
//
//  Created by 钟武 on 16/8/3.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/SDWebImageManager.h>

#import "HTTPManager.h"
#import "BaiduSugResponseModel.h"
#import "HTTPErrorCode.h"

#define MAX_CONCURRENT_HTTP_REQUEST_COUNT 3

#define INTERNAL_TIME_OUT   45

@interface HTTPManager ()

@property (nonatomic, strong) AFHTTPSessionManager *afManager;

@end

@implementation HTTPManager

- (id)init{
    if (self = [super init]) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.HTTPShouldUsePipelining = YES;
        
        _afManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:sessionConfiguration];
        [_afManager.operationQueue setMaxConcurrentOperationCount:MAX_CONCURRENT_HTTP_REQUEST_COUNT];
        _afManager.completionQueue = dispatch_queue_create("zw.completion.queue", DISPATCH_QUEUE_SERIAL);
        _afManager.requestSerializer.timeoutInterval = INTERNAL_TIME_OUT;
        
        //百度的sug返回类型为baiduapp/json，所以解析时需要加上该类型
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"baiduapp/json", nil];
        _afManager.responseSerializer = responseSerializer;
    }
    return self;
}

- (void)getImageWithURL:(NSURL *)url completion:(void (^)(UIImage *, NSError *))completion{
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageCacheMemoryOnly progress:nil completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
        dispatch_main_safe_sync(^{
            if (image && completion) {
                completion(image, nil);
                return ;
            }
            
            if (completion && finished) {
                completion(nil, error);
            }
        })
    }];
}
/**
 HTTP Get Method
 */
- (NSURLSessionDataTask *)GET:(NSString *)URLPath parameters:(NSDictionary *)parameters modelClass:(Class)modelClass success:(void (^)(NSURLSessionDataTask *, BaseResponseModel *))success failure:(void (^)(NSURLSessionDataTask *, BaseResponseModel *))failure{
    NSAssert(modelClass, @"modelClass cannot be nil");
    NSAssert(URLPath, @"url path cannot be nil");

    WEAK_REF(self)
    NSURLSessionDataTask *op = [_afManager GET:URLPath parameters:parameters progress:nil success:^(NSURLSessionDataTask *task,id responseObject){
        STRONG_REF(self_)
        if (self__) {
            if ([modelClass isSubclassOfClass:[BaiduSugResponseModel class]]) {
                [self__ parseJSONNoKeySugSuccessResponse:responseObject task:task modelClass:modelClass success:success failure:failure];
            }
            else
                [self__ parseSuccessResponse:responseObject task:task modelClass:modelClass success:success failure:failure];
        }
    }failure:^(NSURLSessionDataTask *task,NSError *error){
        STRONG_REF(self_)
        if (self__) {
            BaseResponseModel *baseModel = [self__ failureResponseModelWithTask:task];
            dispatch_main_safe_async(^{
                if (failure) {
                    failure(task,baseModel);
                }
            })
        }
    }];
    
    return op;
}

- (BaiduSugResponseModel *)createBaiduSugModeWithResponse:(id)responseObject error:(NSError * __autoreleasing *)error{
    BaiduSugResponseModel *model = [BaiduSugResponseModel new];
    
    if ([responseObject isKindOfClass:[NSArray class]]) {
        NSArray *responseArray = (NSArray *)responseObject;
        
        [responseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if ([obj isKindOfClass:[NSString class]]) {
                model.keyword = obj;
            }
            else if ([obj isKindOfClass:[NSArray class]]){
                __block BOOL isString = YES;
                [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                    if (![obj isKindOfClass:[NSString class]]) {
                        isString = NO;
                        *stop = YES;
                    }
                }];
                if (isString) {
                    model.sugArray = obj;
                }
                else
                {
                    NSDictionary *userInfo = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Could not parse JSON", @""),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Baidu Sug Response Error", @"")
                                               };
                    *error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorInvalidJSONMapping userInfo:userInfo];
                }
            }
        }];
    }
    
    return model;
}


/**
 parse no key JSON file
 */
- (void)parseJSONNoKeySugSuccessResponse:(id)responseObject
                       task:(NSURLSessionDataTask *)task
                 modelClass:(Class)modelClass
                    success:(void (^)(NSURLSessionDataTask *, BaseResponseModel *))success
                    failure:(void (^)(NSURLSessionDataTask *, BaseResponseModel *))failure{
    NSError *error;
    
    BaseResponseModel *baseModel = nil;
    
    if ([modelClass isSubclassOfClass:[BaiduSugResponseModel class]]) {
        baseModel = [self createBaiduSugModeWithResponse:responseObject error:&error];
    }
    
    dispatch_main_safe_async(^{
        if (error) {
            if (failure) {
                BaseResponseModel *errorModel = [[BaseResponseModel alloc] initWithErrorCode:HttpRequestParseErrorType errorMsg:@"解析错误"];
                failure(task, errorModel);
            }
        }
        else{
            if (success) {
                success(task, baseModel);
            }
        }
    })
}

- (void)parseSuccessResponse:(id)responseObject
                  task:(NSURLSessionDataTask *)task
                 modelClass:(Class)modelClass
                    success:(void (^)(NSURLSessionDataTask *, BaseResponseModel *))success
                    failure:(void (^)(NSURLSessionDataTask *, BaseResponseModel *))failure{
    NSError *error;
    BaseResponseModel *baseModel = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:responseObject error:&error];
    
    dispatch_main_safe_async(^{
        if (error) {
            if (failure) {
                BaseResponseModel *errorModel = [[BaseResponseModel alloc] initWithErrorCode:HttpRequestParseErrorType errorMsg:@"解析错误"];
                failure(task, errorModel);
            }
        }
        else{
            if (success) {
                success(task, baseModel);
            }
        }
    })
}

- (BaseResponseModel *)failureResponseModelWithTask:(NSURLSessionDataTask *)op
{
    NSError *error = [op error];
    
    int errorCode = HttpRequestGeneralErrorType;
    
    switch ([error code]) {
        case NSURLErrorTimedOut:
            errorCode = HttpRequestTimedOutErrorType;
            break;
            
        case NSURLErrorCancelled:
            errorCode = HttpRequestCancelErrorType;
            break;
            
        case NSURLErrorUnsupportedURL:
        case NSURLErrorCannotFindHost:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorHTTPTooManyRedirects:
            errorCode = HttpConnectionFailureErrorType;
            break;
        default:
            errorCode = HttpRequestGeneralErrorType;
            break;
    }
    
    BaseResponseModel *errorModel = [[BaseResponseModel alloc] initWithErrorCode:errorCode errorMsg:[error description]];
    return errorModel;
    
}


@end
