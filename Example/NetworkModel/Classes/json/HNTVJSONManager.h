//
//  HNTVJSONManager.h
//  NetworkModel
//
//  Created by Che Yongzi on 2017/4/6.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "HNTVRequestOperation.h"
#import "HNTVJsonModelProtocol.h"
#import "NetworkConfig.h"
#import "JsonDataCache.h"

@interface HNTVJSONManager : NSObject

@property (nonatomic, weak) id<HNTVBaseModelDelegate> model;

- (instancetype)initWithBaseURL:(NSURL *)url;

@property (nonatomic, strong) NSURL *baseURL;

@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) AFHTTPSessionManager        *sessionManager;

//加载本地缓存
- (id)checkCache:(NSString *)method
       URLString:(NSString *)URLString
      parameters:(NSDictionary *)parameters;

//更新本地缓存
- (BOOL)updateCache:(NSString *)method
          URLString:(NSString *)URLString
         parameters:(NSDictionary *)parameters
        enableCache:(BOOL)enableCache
    processedObject:(id<HNTVJsonModelProtocol>)processedObject;


/**
 *  查找本地缓存
 *
 *  @param method     请求 Method
 *  @param URLString  请求串
 *  @param parameters 请求 参数
 *  @param classType  映射对象
 *
 *  @return 映射后的对象
 */
- (id)fetchLocalCache:(NSString *)method
            URLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
            classType:(Class)classType;

/**
 *  处理JSON请求返回数据
 *
 *  @param operation      opreation
 *  @param responseObject 返回对象(NSData)
 *  @param classType      映射类型
 *  @param responseType   返回数据格式 Json XML
 *  @param success        成功block
 *  @param failure        失败block
 *
 *  @return 映射后的对象
 */
- (id)processResponseObject:(HNTVRequestOperation *)request
              reponseObject:(id)responseObject
                  classType:(Class)classType
               responseType:(NSInteger)responseType
                    success:(void (^)(HNTVRequestOperation *operation, id responseObject))success
                    failure:(void (^)(HNTVRequestOperation *operation, NSError *error))failure;



/**
 *  上报网络错误
 *
 *  @param operation operation
 *  @param error     error
 */
- (void)processRecordFailure:(HNTVRequestOperation *)operation error:(NSError *)error;

/// 设置启用Metrics
- (void)setMetrics;
@end
