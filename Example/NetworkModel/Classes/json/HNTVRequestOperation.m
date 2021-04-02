//
//  HNTVRequestOperation.m
//  NetworkModel
//
//  Created by yanyun on 15/5/8.
//  Copyright (c) 2015年 com.hunantv. All rights reserved.
//

#import "HNTVRequestOperation.h"
#import "NetworkModel.h"

@implementation HNTVRequestOperation


- (instancetype)init {
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setCompletionBlock:(void (^)(HNTVRequestOperation *, id))success failure:(void (^)(HNTVRequestOperation *, NSError *))failure {
    _successBlock = success;
    _failureBlock = failure;
}

- (void)startOperation {
    [[NetworkModel sharedModel] requestWithOperation:self];
}

- (void)setCompleteTime:(NSTimeInterval)completeTime{
    _completeTime = completeTime;
    
    if (self.startTime != 0) {
        self.consumeTime = self.completeTime-self.startTime;
    }
}


#pragma NSCopying protocol

- (id)copyWithZone:(NSZone *)zone {
    
    HNTVRequestOperation *operation = (HNTVRequestOperation *)[[self class] allocWithZone:zone];
    
    operation.enableCache = self.enableCache;
    operation.exceptionEnable = self.exceptionEnable;
    operation.useDefaultParams = self.useDefaultParams;
    operation.useSync = self.useSync;
    operation.method = [self.method copy];
    operation.URLString = [self.URLString copy];
    operation.requestParams = [self.requestParams copy];
    operation.customRequestHeaders = [self.customRequestHeaders copy];
    operation.customHttpBody = [self.customHttpBody copy];
    operation.cachePolicy = self.cachePolicy;
    operation.timeoutInterval = self.timeoutInterval;
    operation.classType = self.classType;
    operation.responseType = self.responseType;
    operation.customURLRequest = [self.customURLRequest copy];
    operation.constructingBodyWithBlock = self.constructingBodyWithBlock;
    operation.successBlock = self.successBlock;
    operation.failureBlock = self.failureBlock;
    operation.requestSerializeType = self.requestSerializeType;
    operation.retryTimes = self.retryTimes;
    operation.retryIntervalBlock = self.retryIntervalBlock;
    operation.retryInfo = [self.retryInfo copy];
    operation.orignRequestURL = [self.orignRequestURL copy];
    
    return operation;
}


- (void)dealloc {
    _requestOperation = nil;
    _customRequestHeaders = nil;
    _requestParams = nil;
    _method = nil;
    _URLString = nil;
    _customURLRequest = nil;
    _successBlock = nil;
    _failureBlock = nil;
    _retryIntervalBlock = nil;
}

@end
