//
//  NetworkModel.m
//  TestConroutine
//
//  Created by chengsc on 2021/3/16.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import "NetworkModel.h"
#import "AFNetworking.h"
#import "MetricsModel.h"

@interface NetworkModel () {
    AFURLSessionManager *_manager;
}

@end

@implementation NetworkModel

+ (instancetype)sharedModel {
    static dispatch_once_t onceToken;
    static NetworkModel *sharedModel;
    dispatch_once(&onceToken, ^{
        sharedModel = [[NetworkModel alloc] init];
    });
    return sharedModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 5;
        config.timeoutIntervalForResource = 5;
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        __weak typeof(self) weakSelf = self;
        if (@available(iOS 10.2, *)) {
            [_manager setTaskDidFinishCollectingMetricsBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLSessionTaskMetrics * _Nullable metrics) {
                [weakSelf metricsBlockActionWithSession:session task:task metrics:metrics];
            }];
        }
    }
    return self;
}

- (void)requestWithMethod:(nonnull NSString *)method url:(nonnull NSString *)url params:(nullable NSDictionary *)params {
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:url parameters:params error:nil];

    NSURLSessionDataTask *uploadTask;
    uploadTask = [_manager
                  dataTaskWithRequest:request
                  uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                         
                      });
                } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                    
                } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
//                          NSLog(@"%@ %@", response, responseObject);
                      }
                }];

    [uploadTask resume];
}

- (void)metricsBlockActionWithSession:(NSURLSession *)session task:(NSURLSessionTask*)task metrics:(NSURLSessionTaskMetrics*)metrics {
    @try {
        MetricsModel *metricsModel = [[MetricsModel alloc] init];

        NSURLSessionTaskTransactionMetrics *transactionMetrics = metrics.transactionMetrics.firstObject;
        
        NSString *url = [NSString stringWithFormat:@"%@%@",transactionMetrics.request.URL.host,transactionMetrics.request.URL.path] ;
        metricsModel.url = url;
        
        NSTimeInterval taskInterval = metrics.taskInterval.duration;
        metricsModel.taskInterval = taskInterval;
        
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
        metricsModel.time_DNS = time_DNS;
        
        NSString *domainIP;
        if (@available(iOS 13, *)) {
            if (transactionMetrics.remoteAddress && transactionMetrics.remoteAddress.length > 0) {
                domainIP = transactionMetrics.remoteAddress;
            }
        }
        metricsModel.domainIP = domainIP;
        
        NSTimeInterval time_TCP = 0;
        if (transactionMetrics.connectEndDate.timeIntervalSince1970 > 0) {
            time_TCP = [transactionMetrics.connectEndDate timeIntervalSinceDate:transactionMetrics.connectStartDate];
        }
        metricsModel.time_TCP = time_TCP;
        
        NSTimeInterval time_TLS = 0;
        if (transactionMetrics.secureConnectionEndDate.timeIntervalSince1970 > 0) {
            time_TLS = [transactionMetrics.secureConnectionEndDate timeIntervalSinceDate:transactionMetrics.secureConnectionStartDate];
        }
        
        NSTimeInterval time_Request = 0;
        if (transactionMetrics.requestEndDate.timeIntervalSince1970 > 0) {
            time_Request = [transactionMetrics.requestEndDate timeIntervalSinceDate:transactionMetrics.requestStartDate];
        }
        metricsModel.time_Request = time_Request;
        
        NSTimeInterval time_HTTP = 0;
        if (transactionMetrics.responseStartDate.timeIntervalSince1970 > 0) {
            time_HTTP = [transactionMetrics.responseStartDate timeIntervalSinceDate:transactionMetrics.requestEndDate];
        }
        metricsModel.time_HTTP = time_HTTP;
        
        NSTimeInterval time_Response = 0;
        if (transactionMetrics.responseEndDate.timeIntervalSince1970 > 0) {
            time_Response = [transactionMetrics.responseEndDate timeIntervalSinceDate:transactionMetrics.responseStartDate];
        }
        metricsModel.time_Response = time_Response;
        
        NSTimeInterval time_HTTPRtt = 0;
        if (transactionMetrics.responseStartDate.timeIntervalSince1970 > 0) {
            time_HTTPRtt = [transactionMetrics.responseStartDate timeIntervalSinceDate:transactionMetrics.requestStartDate];
        }

        metricsModel.time_HTTPRtt = time_HTTPRtt;

        int64_t down_h = transactionMetrics.countOfResponseHeaderBytesReceived;
        int64_t down_body = transactionMetrics.countOfResponseBodyBytesReceived;

        metricsModel.down_header = down_h;
        metricsModel.down_body = down_body;

        int64_t up_h = transactionMetrics.countOfRequestHeaderBytesSent;
        int64_t up_body = transactionMetrics.countOfRequestBodyBytesSent;

        metricsModel.up_header = up_h;
        metricsModel.up_body = up_body;
        
        NSTimeInterval t1 = 0;
        if (transactionMetrics.connectStartDate.timeIntervalSince1970 > 0 && transactionMetrics.domainLookupEndDate.timeIntervalSince1970 > 0) {
            t1 = [transactionMetrics.connectStartDate timeIntervalSinceDate:transactionMetrics.domainLookupEndDate];
        }
        NSTimeInterval t2 = 0;
        if (transactionMetrics.requestStartDate.timeIntervalSince1970 > 0 && transactionMetrics.connectEndDate.timeIntervalSince1970 > 0) {
            t2 = [transactionMetrics.requestStartDate timeIntervalSinceDate:transactionMetrics.connectEndDate];
        }
        if (_metricsBlock) {
            _metricsBlock(metricsModel);
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)setupMetricsCallBack:(void (^)(id<NetworkMetrics> _Nonnull))metricsCallback {
    _metricsBlock = metricsCallback;
}
@end
