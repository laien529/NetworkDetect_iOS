//
//  DetectDataProviderProtocol.h
//  NetworkDetect
//
//  Created by chengsc on 2021/4/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NetworkMetrics <NSObject>
@property(nonatomic, strong) NSString *domainIP;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, assign) NSTimeInterval time_DNS;
@property(nonatomic, assign) NSTimeInterval time_TCP;
@property(nonatomic, assign) NSTimeInterval time_Request;
@property(nonatomic, assign) NSTimeInterval time_HTTP;
@property(nonatomic, assign) NSTimeInterval time_Response;
@property(nonatomic, assign) NSTimeInterval taskInterval;
@property(nonatomic, assign) int64_t up_header;
@property(nonatomic, assign) int64_t up_body;
@property(nonatomic, assign) int64_t down_header;
@property(nonatomic, assign) int64_t down_body;
@property(nonatomic, assign) NSTimeInterval time_HTTPRtt;

@end

@protocol DetectDataProviderProtocol <NSObject>

- (void)setupMetricsCallBack:(void(^)(id<NetworkMetrics>)) metricsCallback;

@end

NS_ASSUME_NONNULL_END
