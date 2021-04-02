//
//  NetworkPolicy.m
//  NetworkModel
//
//  Created by Che Yongzi on 2017/8/31.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "NetworkPolicy.h"
#import "MGDisasterModel.h"

#define NETWORK_DEFAULT_RETRY_INTERVAL 3

@interface NetworkPolicy ()

/**
 *  域名替换策略
 */
@property (strong, nonatomic) id<HNTVPolicyProtocol>   hostPolicy;

/**
 *  请求重试策略
 */
@property (strong, nonatomic) id<HNTVPolicyProtocol>   retryPolicy;

@property (strong, nonatomic) HostInfoConfig           *config;

@property (strong, nonatomic) dispatch_queue_t            policyQueue;
/// 需要容灾的域名列表
@property (strong, nonatomic) LHSafeMutableDictionary        *disasterHosts;

@end

@implementation NetworkPolicy

@synthesize disasterConfig;

- (id)initWithData:(id)data {
    if (self = [super init]) {
        if ([data isKindOfClass:[HostInfoConfig class]]) {
            self.policyQueue = dispatch_queue_create("com.mgtv.network.policy.queue", DISPATCH_QUEUE_CONCURRENT);
            self.config = (HostInfoConfig*)data;
            //初始化域名策略和重试策略
            self.hostPolicy = [[NetworkHostPolicy alloc] initWithConfig:self.config];
            self.retryPolicy = [[NetwokRetryPolicy alloc] initWithConfig:self.config];
            self.disasterHosts = [LHSafeMutableDictionary dictionary];
        }
    }
    return self;
}

- (void)updatePolicy:(id)data {
    dispatch_barrier_async(self.policyQueue, ^{
        if (![data isKindOfClass:HostInfoConfig.class]) {
            return;
        }
        self.config = (HostInfoConfig*)data;
        //初始化域名策略和重试策略
        self.hostPolicy = [[NetworkHostPolicy alloc] initWithConfig:self.config];
        self.retryPolicy = [[NetwokRetryPolicy alloc] initWithConfig:self.config];
    });
}

- (BOOL)configOperation:(HNTVRequestOperation *)operation
                  error:(NSError *)error {
    __block BOOL result = NO;
    if (![self judgOperation:operation]) {
        return NO;
    }
    dispatch_sync(self.policyQueue, ^{
        if (!operation.hostInfo) {
            operation.hostInfo = [self.config retryHost:operation.orignRequestURL];
        }
        /*如果传入的error为nil，则认为第一次原始请求，需要替换主域名
         如果传入的error不为nil，则认为是失败之后的重试
         */
        if (!error) {
            [self.hostPolicy configOperation:operation];
        } else {
            //如果NetworkRetryPolicy不存在，则直接返回
            if (self.retryPolicy) {
                result = [self.retryPolicy configOperation:operation];
                if (result) {
                    [self updateRetryInfo:operation error:error isEnd:NO];
                }
            }
        }
    });
    return result;
}

- (void)startRetryRequest:(RetryRequestBlock)retryBlock {
    NSTimeInterval retryInterval = [self retryInterval];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        retryBlock();
    });
}

- (void)updateRetryInfo:(HNTVRequestOperation *)operation error:(NSError *)error isEnd:(BOOL)isEnd {
    if (error) {
        HNTVRequestFailedInfo *failedInfo = [[HNTVRequestFailedInfo alloc] init];
        failedInfo.failedRequest = operation.requestOperation.request;
        failedInfo.error = error;
        failedInfo.httpCode = [NSString stringWithFormat:@"%ld",(long)operation.requestOperation.response.statusCode];
        //最后一次失败不需要算重试次数
        if (!isEnd) {
            operation.retryInfo.retryCount += 1;
        }
        [operation.retryInfo.failedInfos addObject:failedInfo];
    } else {
        operation.retryInfo.successRequest = operation.requestOperation.request;
    }
}

/**
 判断HNTVRequestOperation的一些属性是否不需要进行重试

 @param operation HNTVRequestOperation
 @return BOOL
 */
- (BOOL)judgOperation:(HNTVRequestOperation*)operation {
    BOOL result = YES;
    //ignoreRetry忽略重试
    if (operation.ignoreRetry) {
        result = NO;
    }
    //过滤POST请求
    if ([operation.method caseInsensitiveCompare:@"POST"] == NSOrderedSame) {
        result = NO;
    }
    //判断网络状态
    if ([[HNTVReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        result = NO;
    }
    return result;
}

/**
 获取失败请求发起的间隔时间

 @return NSTimeInterval
 */
- (NSTimeInterval)retryInterval {
    if (self.config && self.config.retryInterval && self.config.retryInterval.integerValue >= 0) {
        return self.config.retryInterval.doubleValue;
    }
    return NETWORK_DEFAULT_RETRY_INTERVAL;
}

- (BOOL)inDisasterRequest:(HNTVRequestOperation *)operation{
    if (self.disasterConfig == 0) {
        return false;
    }
    __block BOOL result = false;
    NSString *host = [NSURL URLWithString:operation.URLString].host;
    if (host.length == 0) {
        return result;
    }
    MGDisasterModel *disasterModel = self.disasterHosts[host];
    if (!disasterModel || ![disasterModel isKindOfClass:MGDisasterModel.class]) {
        return result;
    }
    MGDisasterResult value = [disasterModel isDisaster];
    switch (value) {
        case MGDisasterValid:
            result = true;
            break;
        case MGDisasterInValid:
        {
            [self.disasterHosts removeObjectForKey:host];
            disasterModel = nil;
        }
            break;
    }
    return true;
}

- (BOOL)disasterRequest:(HNTVRequestOperation *)operation response:(NSHTTPURLResponse *)response{
    /// 错误码不为503则直接返回
    if (response.statusCode != 503 || self.disasterConfig == 0) {
        return false;
    }
    id value = response.allHeaderFields[@"Retry-After"];
    /// 如果返回头不包含Retry-After,则直接返回
    if (!value || 0>=[[NSString stringWithFormat:@"%@",value] intValue]) {
        return false;
    }
    NSString *host = [NSURL URLWithString:operation.URLString].host;
    NSInteger duration = [value intValue] > 300 ? 300 : [value intValue];
    MGDisasterModel *model = [MGDisasterModel new];
    model.disassterTime = [NSDate timeIntervalSinceReferenceDate];
    model.disasterDuration = duration;
    model.host = host;
    [self.disasterHosts setObject:model forKey:host];
    return true;
}

@end

@implementation MGRequsetReportPolicy

@end
