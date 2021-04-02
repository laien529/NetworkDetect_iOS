//
//  RetryPolicy.m
//  NetworkModel
//
//  Created by Che Yongzi on 2017/8/31.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "NetwokRetryPolicy.h"

#define NETWORK_DEFAULT_RETRY_HOST_TIMEOUT 10

@interface NetwokRetryPolicy ()

@property (weak, nonatomic) HostInfoConfig  *config;

@end

@implementation NetwokRetryPolicy

- (id)initWithConfig:(HostInfoConfig *)config {
    if (self = [super init]) {
        self.config = config;
    }
    return self;
}

- (BOOL)configOperation:(HNTVRequestOperation *)operation {
    BOOL result = NO;
    /*
     1、不允许进行重试
     2、不存在重试域名
     */
    if (self.config.retryStatus.integerValue == 0 ||
        !operation.hostInfo) {
        return result;
    }
    //重试的次数大于重试域名的数组个数
    if (operation.retryInfo.retryCount >= operation.hostInfo.backup.count) {
        return result;
    }
    if (!operation.retryInfo) {
        operation.retryInfo = [[HNTVRequestRetryInfo alloc] init];
    }
    //重新设置Operation的属性
    result = [self resetOperation:operation];
    return result;
}

- (BOOL)resetOperation:(HNTVRequestOperation*)operation {
    NSString *operationPath = operation.orignRequestURL.path;
    NSString *queryString = operation.orignRequestURL.query;
    NSString *retryHost = operation.hostInfo.backup[operation.retryInfo.retryCount];
    //拼接URL
    operation.URLString = [NSString stringWithFormat:@"%@%@",retryHost, operationPath];
    if (![queryString isEqualToString:@""] && queryString) {
        operation.URLString = [NSString stringWithFormat:@"%@?%@",operation.URLString, queryString];
    }
    //根据配置信息设置请求的超时时间
    operation.timeoutInterval = self.config.backupHostTimeout > 0 ? self.config.backupHostTimeout.integerValue : NETWORK_DEFAULT_RETRY_HOST_TIMEOUT;
    return YES;
}

@end
