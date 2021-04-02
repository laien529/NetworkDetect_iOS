//
//  NetworkHostPolicy.m
//  NetworkModel
//
//  Created by Che Yongzi on 2017/8/30.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "NetworkHostPolicy.h"

#define NETWORK_DEFAULT_MAIN_HOST_TIMEOUT 10

@interface NetworkHostPolicy ()

@property (weak, nonatomic) HostInfoConfig  *config;

@end

@implementation NetworkHostPolicy

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
    if (self.config.masterStatus.integerValue == 0 ||
        !operation.hostInfo) {
        return result;
    }
    //下发的替换域名不存在则返回
    if (!operation.hostInfo.master || [operation.hostInfo.master isEqualToString:@""]) {
        return result;
    }
    result = [self resetOperation:operation];
    return result;
}

- (BOOL)resetOperation:(HNTVRequestOperation*)operation {
    NSString *operationPath = operation.orignRequestURL.path;
    NSString *queryString = operation.orignRequestURL.query;
    NSString *retryHost = operation.hostInfo.master;
    NSString *orignHost = [NSString stringWithFormat:@"%@://%@",operation.orignRequestURL.scheme, operation.orignRequestURL.host];
    if (![orignHost isEqualToString:operation.hostInfo.host]) {
        return NO;
    }
    //拼接URL
    operation.URLString = [NSString stringWithFormat:@"%@%@",retryHost, operationPath];
    if (![queryString isEqualToString:@""] && queryString) {
        operation.URLString = [NSString stringWithFormat:@"%@?%@",operation.URLString, queryString];
    }
    //根据配置信息设置请求的超时时间
    operation.timeoutInterval = [self mainHostTimeout];
    return YES;
}

/**
 获取主域名的超时时间

 @return NSInteger
 */
- (NSInteger)mainHostTimeout {
    if (self.config &&
        self.config.mainHostTimeout &&
        self.config.mainHostTimeout.integerValue > 0) {
        
        return self.config.mainHostTimeout.integerValue;
    }
    return NETWORK_DEFAULT_MAIN_HOST_TIMEOUT;
}

@end
