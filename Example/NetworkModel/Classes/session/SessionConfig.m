//
//  SessionConfig.m
//  NetworkModel
//
//  Created by cheyongzi on 2017/12/5.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "SessionConfig.h"

@implementation SessionConfig

- (BOOL)isAllowSession:(HNTVRequestOperation *)operation {
    if (self.useSessionTask.integerValue == 0) {
        return NO;
    }
    if ([self.blackList containsObject:operation.orignRequestURL.host]) {
        return NO;
    }
    if (!self.whiteList || self.whiteList.count == 0) {
        return YES;
    }
    if (![self.whiteList containsObject:operation.orignRequestURL.path]) {
        for (NSString* path in self.whiteList) {
            if ([operation.orignRequestURL.path rangeOfString:path].location != NSNotFound) {
                return YES;
            }
        }
        return NO;
    }
    return YES;
}

- (BOOL)isAllowMetrics:(NSURL *)url {
    if (self.useMetrics.integerValue == 0) {
        return NO;
    }
    NSString *preMatchUrl = [NSString stringWithFormat:@"%@%@", url.host, url.path];
    if (![self.metricsAPIList containsObject:preMatchUrl]) {
        for (NSString* path in self.metricsAPIList) {
            if ([preMatchUrl rangeOfString:path].location != NSNotFound) {
                return YES;
            }
        }
        return NO;
    }
    return YES;
}

@end
