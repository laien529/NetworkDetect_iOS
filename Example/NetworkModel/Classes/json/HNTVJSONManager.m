//
//  HNTVJSONManager.m
//  NetworkModel
//
//  Created by Che Yongzi on 2017/4/6.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "HNTVJSONManager.h"
#import "MGUmengDataReport.h"

@interface HNTVJSONManager ()

@end

@implementation HNTVJSONManager

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super init]) {
        _baseURL = url;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (id)checkCache:(NSString *)method
       URLString:(NSString *)URLString
      parameters:(NSDictionary *)parameters {
    
    NSString * key = [self makeRequestKey:method URLString:URLString parameters:parameters];
    
    id object = [[JsonDataCache singleton] loadFromDiskWithKey:key];
    
    return object;
}


- (BOOL)updateCache:(NSString *)method
          URLString:(NSString *)URLString
         parameters:(NSDictionary *)parameters
        enableCache:(BOOL)enableCache
    processedObject:(id<HNTVJsonModelProtocol>)processedObject {
    
    BOOL isValid = NO;
    BOOL needUpdate = NO; //是否需要更新本地缓存
    NSString * key = @"";
    //更新缓存
    @try {
        if ([processedObject conformsToProtocol:@protocol(HNTVJsonModelProtocol)]) {
            key = [self makeRequestKey:method URLString:URLString parameters:parameters];
            
            isValid = [processedObject validate];
            
            if (isValid)
                needUpdate = [[JsonDataCache singleton] needUpdateCacheWithData:processedObject key:key];
            
            //如果允许缓存，并且与上次缓存的数据不一致，更新缓存
            if (enableCache && isValid && needUpdate)
                [[JsonDataCache singleton] saveData:processedObject toDiskWithKey:key];
        }
    }
    @catch (NSException *exception) {
        DDLogDebug(@"%s updateCache  exception = %@", __func__, [exception description]);
    }
    @finally {
        
    }
    
    BOOL needCallBack = NO;
    if (needUpdate
        || !enableCache
        || ![self existCacheForKey:key]) {
        needCallBack = YES;
    }
    
    return needCallBack;
}


- (NSString *)makeRequestKey:(NSString *)method
                   URLString:(NSString *)URLString
                  parameters:(NSDictionary *)parameters {
    
    NSString * requestURLString = [[NSURL URLWithString:URLString relativeToURL:_baseURL] absoluteString];
    //移除特殊字段
    NSMutableDictionary * mutableParameters = nil;
    if (parameters) {
        mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters ? parameters : @{}];
        [mutableParameters removeObjectsForKeys:@[@"mac",@"osVersion",@"seqId",@"ticket"]];
    }
    
    NSString *key = [NSString stringWithFormat:@"Method:%@ Url:%@ Argument:%@", method, requestURLString, mutableParameters ? mutableParameters : @""];
    return key;
}


- (BOOL)existCacheForKey:(NSString *)key {
    BOOL exist = NO;
    id object = [[JsonDataCache singleton] loadFromDiskWithKey:key];
    exist = (object != nil);
    
    return exist;
}


- (id)parseResponseData:(NSData *)plainTextData responseType:(NSInteger)responseType parsingError:(NSError *)parsingError {
    
    id parsedObject = nil;
    
    switch (responseType) {
        case HNTVResponseContentTypePlainText: {
            parsedObject = plainTextData;
            break;
        }
        case HNTVResponseContentTypeJson: {
            parsedObject = [NSJSONSerialization JSONObjectWithData:plainTextData options:kNilOptions error:&parsingError];
            
            break;
        }
        case HNTVResponseContentTypeXML: {
            //TODO:XML解析
            break;
        }
        default:
            break;
    }
    
    return parsedObject;
}

#pragma mark - Local Cache Process
//处理本地缓存（查找，读取）
- (id)fetchLocalCache:(NSString *)method
            URLString:(NSString *)URLString
           parameters:(NSDictionary *)parameters
            classType:(Class)classType {
    //本地缓存处理
    id object = nil;
    @try {
        id cachedObject = [self checkCache:method URLString:URLString parameters:parameters];
        
        //映射
        if (classType && cachedObject) {
            
            if ([cachedObject isKindOfClass:classType]) {
                
                object = cachedObject;
            }
            if ([object respondsToSelector:@selector(setIsFromCache:)])
                [object setIsFromCache:YES];
        }
    }
    @catch (NSException *exception) {
        DDLogDebug(@"%s processLocalCache exception = %@", __func__, [exception description]);
    }
    @finally {
        
    }
    return object;
}


- (id)processResponseObject:(HNTVRequestOperation *)operation
              reponseObject:(id)responseObject
                  classType:(Class)classType
               responseType:(NSInteger)responseType
                    success:(void (^)(HNTVRequestOperation *operation, id responseObject))success
                    failure:(void (^)(HNTVRequestOperation *operation, NSError *error))failure {
    
    DDLogDebug(@"%s processResponseObject url = %@, statusCode = %@, responseObject = %@", __func__, operation.requestOperation.request.URL.absoluteString, @(operation.requestOperation.response.statusCode), responseObject ? [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] : @"");
    
    
    NSHTTPURLResponse *response = operation.requestOperation.response;
    
    //首先判断网络接口返回的statusCode是否为200，非200表示接口错误，这里需要做重试
    if (response.statusCode != 200) {
        if ([self networkConfig].canStatistics.boolValue) {
            NSString *errorString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            [NSObject publish:kStatisticsModelRecordNotification data:@{kStatisticsModelKeyErrorCode:[NSString stringWithFormat:@"%@10%ld", C_API, (long)response.statusCode], kStatisticsModelKeyErrorDetail:[NSString stringWithFormat:@"errorDesc:http request failured____url:%@____statusCode:%ld____response:%@", response.URL.absoluteString, (long)response.statusCode, errorString], kStatisticsModelKeyErrorUrl:operation.requestOperation.request.URL?:@""}];
        }
    }
    
    
    NSData * plainTextData = responseObject;
    //如果是映射对象，过滤HTML
    NSString * plainTextString;
    if ([self networkConfig].canFilterHTML.boolValue && responseType != HNTVResponseContentTypePlainText) {
        @try {
            plainTextString = [[NSString alloc] initWithData:plainTextData encoding:NSUTF8StringEncoding];
            plainTextString = [plainTextString stringByConvertingHTMLToPlainText];
            plainTextData = [plainTextString dataUsingEncoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            DDLogDebug(@"%s processResponseObject filter html tag exception = %@", __func__, [exception description]);
        }
        @finally {
            
        }
    }
    
    //解析接口数据转换成JSON数据
    id object = nil;
    id parsedObject = nil;
    NSError * parsingError = nil;
    NSError * mappingError = nil;
    @try {
        parsedObject = [self parseResponseData:plainTextData responseType:responseType parsingError:parsingError];
    }
    @catch (NSException *exception) {
        DDLogDebug(@"%s processResponseObject json parse exception = %@", __func__, [exception description]);
        if (failure) {
            failure(operation, [NSError errorWithDomain:@"hntv.json.parse" code:0 userInfo:@{NSLocalizedDescriptionKey: @"json parse exception."}]);
        }
        return nil;
    }
    @finally {
        
    }
    
    //如果接口数据转换失败，则需要进行重试
    if (!parsedObject) {
        if ([self networkConfig].canStatistics.boolValue) {
            NSString *errorString = [[NSString alloc] initWithData:plainTextData encoding:NSUTF8StringEncoding];
            [NSObject publish:kStatisticsModelRecordNotification data:@{kStatisticsModelKeyErrorCode:[NSString stringWithFormat:@"%@%@", C_API, A_JSON], kStatisticsModelKeyErrorDetail:[NSString stringWithFormat:@"url:%@____response:%@____errorMessage:%@____errorDesc:JSON解析错误", operation.requestOperation.request.URL.absoluteString, errorString,[parsingError localizedDescription]], kStatisticsModelKeyErrorUrl:operation.requestOperation.request.URL?:@""}];
        }
        
        @try {
            if (failure) {
                failure(operation, [NSError errorWithDomain:@"hntv.json.parse" code:0 userInfo:@{NSLocalizedDescriptionKey: @"json parse failed."}]);
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        
        return nil;
    }
    
    //映射
    @try {
        
        if (classType) {
            //如果接口返回数据是JSONModel类型，则需要判断转换是否成功，出错则需要重试
            if ([parsedObject isKindOfClass:[NSDictionary class]]) {
                
                object = [[classType alloc] initWithDictionary:parsedObject error:&mappingError];
                if (mappingError) {
                    DDLogDebug(@"%s processResponseObject json mapping failed = %@", __func__, [mappingError localizedDescription]);
                    if (failure) {
                        failure(operation, mappingError);
                    }
                    return nil;
                }
                
            } else {
                if (failure) {
                    failure(operation, [NSError errorWithDomain:@"hntv.json.parse" code:0 userInfo:@{NSLocalizedDescriptionKey: @"json mapping error params."}]);
                }
            }
            if ([object conformsToProtocol:@protocol(HNTVJsonModelProtocol)])
                [object setIsFromCache:NO];
        } else {
            //如果映射类型为空，表示直接返回NSData数据
            if (!classType && success) {
                success(operation, parsedObject == nil ? responseObject : parsedObject);
            }
            return nil;
        }
    }
    @catch (NSException *exception) {
        //解析过程中出错 则需要重试
        DDLogDebug(@"%s processResponseObject json mapping exception = %@", __func__, [exception description]);
        if (failure) {
            failure(operation, [NSError errorWithDomain:@"hntv.json.mapping" code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"json mapping exception.%@", [exception description]]}]);
        }
        //TODO:异常错误上报
        return nil;
    }
    @finally {
        
    }
    
    return object;
}


- (id)processXMLResponseObject:(AFHTTPRequestOperation *)operation
                 reponseObject:(id)responseObject
                     classType:(Class)classType
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    return nil;
}

/**
 *  上报网络错误
 *
 *  @param operation operation
 *  @param error     error
 */
- (void)processRecordFailure:(HNTVRequestOperation *)operation error:(NSError *)error {
    if (error.code == NSURLErrorNetworkConnectionLost || error.code == NSURLErrorCancelled) {
        return;
    }
    NSString *errorDesc = A_TIMEOUT;
    //需要针对DNS解析失败的做特殊处理
    if (error.code == NSURLErrorCannotFindHost||
        error.code == NSURLErrorDNSLookupFailed) {
        errorDesc = A_DNS_Error;
    }
    NSHTTPURLResponse *reponse = operation.requestOperation.response;
    if (reponse && reponse.statusCode > 0) {
        errorDesc = [NSString stringWithFormat:@"10%@", @(reponse.statusCode)];
    }
    NSDictionary *userInfo = [error userInfo];
    NSString *description = [userInfo objectForKey:NSLocalizedDescriptionKey];
    if (!description) {
        description = [error localizedDescription];
    }
    NSURL *errUrl = operation.requestOperation.request.URL;
    NSString *urlString = errUrl.absoluteString;
    if ([self networkConfig].canStatistics.boolValue && error.code != 0 && urlString.length > 0 && description.length > 0) {
        [NSObject publish:kStatisticsModelRecordNotification data:@{kStatisticsModelKeyErrorCode:[NSString stringWithFormat:@"%@%@", C_API, errorDesc], kStatisticsModelKeyErrorDetail:[NSString stringWithFormat:@"url:%@____errorMessage:%@@", urlString, description], kStatisticsModelKeyErrorUrl:errUrl?errUrl:@""}];
    }
}

- (NetworkConfig *)networkConfig {
    
    NetworkConfig * config = nil;
    
    if ([self.model.config isKindOfClass:[NetworkConfig class]]) {
        config = (NetworkConfig *)self.model.config;
    }
    return config;
}

#pragma mark - Serial
//- (void)setRequestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer {
//    _operationManager.requestSerializer = requestSerializer;
//    _sessionManager.requestSerializer = requestSerializer;
//}

#pragma mark- --Metrics
- (void)metricsBlockActionWithSession:(NSURLSession *)session task:(NSURLSessionTask*)task metrics:(NSURLSessionTaskMetrics*)metrics {
    @try {
        if (![NetworkModel.sharedModel.sessionConfig isAllowMetrics:task.originalRequest.URL]) {
            return;
        }
        NSURLSessionTaskTransactionMetrics *transactionMetrics = metrics.transactionMetrics.firstObject;
        
        NSString *url = [NSString stringWithFormat:@"%@%@",transactionMetrics.request.URL.host,transactionMetrics.request.URL.path] ;

        NSTimeInterval taskInterval = metrics.taskInterval.duration;
        NSTimeInterval time_TaskInit;
        if (transactionMetrics.domainLookupStartDate.timeIntervalSince1970 > 0) {
            time_TaskInit = [transactionMetrics.domainLookupStartDate timeIntervalSinceDate:transactionMetrics.fetchStartDate];
        } else if (transactionMetrics.requestStartDate.timeIntervalSince1970 > 0) {
            time_TaskInit = [transactionMetrics.requestStartDate timeIntervalSinceDate:transactionMetrics.fetchStartDate];
        }
        NSTimeInterval time_DNS = 0;
        if (transactionMetrics.domainLookupEndDate.timeIntervalSince1970 > 0) {
            time_DNS = [transactionMetrics.domainLookupEndDate timeIntervalSinceDate:transactionMetrics.domainLookupStartDate];
        }
        NSString *domainIP;
        if (@available(iOS 13, *)) {
            if (transactionMetrics.remoteAddress && transactionMetrics.remoteAddress.length > 0) {
                domainIP = transactionMetrics.remoteAddress;
            }
        }
        NSTimeInterval time_TCP = 0;
        if (transactionMetrics.connectEndDate.timeIntervalSince1970 > 0) {
            time_TCP = [transactionMetrics.connectEndDate timeIntervalSinceDate:transactionMetrics.connectStartDate];
        }
        NSTimeInterval time_TLS = 0;
        if (transactionMetrics.secureConnectionEndDate.timeIntervalSince1970 > 0) {
            time_TLS = [transactionMetrics.secureConnectionEndDate timeIntervalSinceDate:transactionMetrics.secureConnectionStartDate];
        }
        NSTimeInterval time_Request = 0;
        if (transactionMetrics.requestEndDate.timeIntervalSince1970 > 0) {
            time_Request = [transactionMetrics.requestEndDate timeIntervalSinceDate:transactionMetrics.requestStartDate];
        }
        NSTimeInterval time_HTTP = 0;
        if (transactionMetrics.responseStartDate.timeIntervalSince1970 > 0) {
            time_HTTP = [transactionMetrics.responseStartDate timeIntervalSinceDate:transactionMetrics.requestEndDate];
        }
        NSTimeInterval time_Response = 0;
        if (transactionMetrics.responseEndDate.timeIntervalSince1970 > 0) {
            time_Response = [transactionMetrics.responseEndDate timeIntervalSinceDate:transactionMetrics.responseStartDate];
        }
        NSTimeInterval t1 = 0;
        if (transactionMetrics.connectStartDate.timeIntervalSince1970 > 0 && transactionMetrics.domainLookupEndDate.timeIntervalSince1970 > 0) {
            t1 = [transactionMetrics.connectStartDate timeIntervalSinceDate:transactionMetrics.domainLookupEndDate];
        }
        NSTimeInterval t2 = 0;
        if (transactionMetrics.requestStartDate.timeIntervalSince1970 > 0 && transactionMetrics.connectEndDate.timeIntervalSince1970 > 0) {
            t2 = [transactionMetrics.requestStartDate timeIntervalSinceDate:transactionMetrics.connectEndDate];
        }
    
        [MGUMengDataReport consumeReport:@"Api-Metrics"
                                interval:taskInterval
                            externalInfo:@{@"url":kUnNilStr(url),
                                           @"Interval":[NSString stringWithFormat:@"%.0lf",taskInterval*1000],
                                           @"TaskInit":[NSString stringWithFormat:@"%.0lf",time_TaskInit*1000],
                                           @"DNS":[NSString stringWithFormat:@"%.0lf",time_DNS*1000],
                                           @"domainIP":kUnNilStr(domainIP) ,
                                           @"TCP":[NSString stringWithFormat:@"%.0lf",time_TCP*1000],
                                           @"TLS":[NSString stringWithFormat:@"%.0lf",time_TLS*1000],
                                           @"Request":[NSString stringWithFormat:@"%.0lf",time_Request*1000],
                                           @"HTTP":[NSString stringWithFormat:@"%.0lf",time_HTTP*1000],
                                           @"Response":[NSString stringWithFormat:@"%.0lf",time_Response*1000],
                                           @"t1":[NSString stringWithFormat:@"%.0lf",t1*1000],
                                           @"t2":[NSString stringWithFormat:@"%.0lf",t2*1000]
                            }];

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)setMetrics {
    @try {
        __weak typeof(self) weakSelf = self;
        if (@available(iOS 10.2, *)) {
            [_sessionManager setTaskDidFinishCollectingMetricsBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLSessionTaskMetrics * _Nullable metrics) {
                [weakSelf metricsBlockActionWithSession:session task:task metrics:metrics];
            }];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
@end
