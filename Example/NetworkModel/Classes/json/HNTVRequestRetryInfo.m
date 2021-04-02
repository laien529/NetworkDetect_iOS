//
//  HNTVRequestRetryInfo.m
//  NetworkModel
//
//  Created by Che Yongzi on 2016/12/27.
//  Copyright © 2016年 Cheyongzi. All rights reserved.
//

#import "HNTVRequestRetryInfo.h"

@implementation HNTVRequestFailedInfo

- (instancetype)init {
    if (self = [super init]) {
        self.failedRequest = nil;
        self.error = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    HNTVRequestFailedInfo *info = (HNTVRequestFailedInfo*)[[self class] allocWithZone:zone];
    info.failedRequest = [self.failedRequest copy];
    info.error = [self.error copy];
    info.httpCode = [self.httpCode copy];
    return info;
}

@end

@implementation HNTVRequestRetryInfo

- (instancetype)init {
    if (self = [super init]) {
        self.retryCount = 0;
        self.failedInfos = [NSMutableArray array];
        self.successRequest = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    HNTVRequestRetryInfo *info = (HNTVRequestRetryInfo*)[[self class] allocWithZone:zone];
    info.retryCount = self.retryCount;
    info.failedInfos = [self.failedInfos mutableCopy];
    info.successRequest = [self.successRequest copy];
    return info;
}

@end
