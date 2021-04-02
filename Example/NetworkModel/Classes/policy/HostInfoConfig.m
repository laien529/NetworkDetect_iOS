//
//  HostInfoConfig.m
//  NetworkModel
//
//  Created by Che Yongzi on 2017/8/30.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "HostInfoConfig.h"

@implementation HostInfo

@end

@implementation HostInfoConfig

/**
 根据请求的域名和路径查找可重试的域名数组
 
 @param orignHost
 @return NSArray
 */
- (HostInfo *)retryHost:(NSURL *)orignURL{
    //config下发的匹配规则为scheme://host
    /*
     2018年03月12号优化为重试匹配域名，不匹配scheme
     */
    NSString *orignDomain = orignURL.host;
    //如果retryHost为空，则直接返回nil
    if (!self.retryHosts || self.retryHosts.count == 0) {
        return nil;
    }
    
    __block HostInfo *retryInfo = nil;
    [self.retryHosts enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(HostInfo*  _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *retryHostURL = [NSURL URLWithString:info.host];
        if (retryHostURL && [retryHostURL.host isEqualToString:orignDomain]) {
            retryInfo = info;
            *stop = YES;
        }
    }];
    return retryInfo;
}

@end
