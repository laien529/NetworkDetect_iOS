//
//  HNTVRequestOperation.h
//  NetworkModel
//
//  Created by yanyun on 15/5/8.
//  Copyright (c) 2015年 com.hunantv. All rights reserved.
//
//

#import "NetworkModelDefines.h"
#import "HNTVRequestRetryInfo.h"
#import "HNTVOperationObject.h"
#import "AFURLRequestSerialization.h"

@class HostInfo;

typedef enum {
    HNTVResponseContentTypePlainText,
    HNTVResponseContentTypeJson,
    HNTVResponseContentTypeXML,
    HNTVResponseContentTypeImage,
    HNTVResponseContentTypeFile
} HNTVResponseContentType;

typedef NSTimeInterval (^RetryIntervalBlock)(NSInteger retryTimes);

@interface HNTVRequestOperation : NSObject<NSCopying>

//@property (nonatomic, weak) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) HNTVOperationObject *requestOperation;
/**
 *  请求自定义tag, 默认为nil
 */
@property (nonatomic, strong) NSString * tag;
/**
 *  是否允许缓存
 */
@property (nonatomic, assign) BOOL enableCache;
/**
 *  是否允许错误上报
 */
@property (nonatomic, assign) BOOL exceptionEnable;
/**
 *  是否使用默认参数
 */
@property (nonatomic, assign) BOOL useDefaultParams;
/**
 *  是否使用同步方式
 */
@property (nonatomic, assign) BOOL useSync;
/**
 *  GET/POST
 */
@property (nonatomic, strong) NSString * method;
/**
 *  请求路径
 */
@property (nonatomic, strong) NSString * URLString;
/**
 *  请求参数
 */
@property (nonatomic, strong) NSDictionary * requestParams;
/**
 *  HTTP Headers
 */
@property (nonatomic, strong) NSDictionary * customRequestHeaders;
/**
 *  HTTP Body 忽略其他Body内容
 */
@property (nonatomic, strong) NSData * customHttpBody;
/**
 *  缓存策略
 */
@property NSURLRequestCachePolicy cachePolicy;
/**
 *  超时时间
 */
@property NSTimeInterval timeoutInterval;
/**
 *  映射对象类型
 */
@property (nonatomic, assign) Class classType;
@property (nonatomic, assign) HNTVResponseContentType responseType;
/**
 *  自定义Request，忽略所有其他的属性
 */
@property (nonatomic, strong) NSURLRequest * customURLRequest;
/**
 *  上传文件block:[formData appendPartWithFileURL:filePath name:@"image" error:nil];
 */
@property (nonatomic, copy) void (^constructingBodyWithBlock)(id <AFMultipartFormData> formData);
/**
 *  成功回调
 */
@property (nonatomic, copy) void (^successBlock)(HNTVRequestOperation *operation, id responseObject);
/**
 *  失败回调
 */
@property (nonatomic, copy) void (^failureBlock)(HNTVRequestOperation *operation, NSError *error);

/// RAM缓存回调，请求的接口，缓存的接口数据
@property (nonatomic, copy) void (^ramCacheBlock)(HNTVRequestOperation *operation, id responseObject);
/**
 *  请求序列类型(0 : plainText, 1: Json)
 */
@property (nonatomic, assign) NetworkModelRequestSerializerType requestSerializeType;
/**
 *  重试次数(包含第一次请求次数)
 */
@property (nonatomic, assign) NSInteger retryTimes;
/**
 *  重试间隔时间方式(间隔次数递减)
 */
@property (nonatomic, copy) RetryIntervalBlock retryIntervalBlock;

//MARK: 这里需要增加几个属性用于网络重试
/*
    1、orignRequestHost:表示网络请求的最初的请求域名
    3、retryInfo:表示请求的重试信息，不进行重试的请求，retryInfo为nil
 */

@property (nonatomic, strong) NSURL                 *orignRequestURL;
@property (nonatomic, strong) HNTVRequestRetryInfo  *retryInfo;
@property (nonatomic, assign) BOOL                  ignoreRetry;
/**
 缓存请求域名信息
 */
@property (nonatomic, strong) HostInfo              *hostInfo;

//是否使用SessionTask请求网络,默认为不使用,后期全部替换之后,可删除该字段
@property (nonatomic, assign) BOOL                  useSessionTask;

/// 内存中的数据缓存路径
@property (nonatomic, copy) NSString                *ramKeyPath;

/// 是否强制刷新接口，忽略ramCache的缓存，但是接口成功如果设置了ram缓存，则同样会根据ramKey进行存储
@property (nonatomic, assign) BOOL                  focusRefresh;

/// 请求的开始时间
@property (nonatomic, assign) NSTimeInterval                  startTime;

/// 请求的完成时间
@property (nonatomic, assign) NSTimeInterval                  completeTime;

/// 请求耗时,如果consumeTime值为0 则认为是从缓存获取的数据
@property (nonatomic, assign) NSTimeInterval                  consumeTime;

/**
 *  上报插件需要的数据
 */
@property (nonatomic, strong) NSDictionary *reportDict;

/**
 *  设置完成Block
 *
 *  @param success 成功
 *  @param failure 失败
 */
- (void)setCompletionBlock:(void (^)(HNTVRequestOperation *operation, id responseObject))success failure:(void (^)(HNTVRequestOperation *operation, NSError *error))failure;

/**
 *  在全局网络模块中启动
 */
- (void)startOperation;

@end
