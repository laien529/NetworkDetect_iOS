//
//  HNTVOperationObject.m
//  NetworkModel
//
//  Created by yanyun on 2017/3/31.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//
//  外观模式 封装AFHTTPReqeustOpertion 和 NSURLSessionDataTask

#import "HNTVOperationObject.h"

@interface HNTVOperationObject()

@property (nonatomic, weak, readonly) AFHTTPRequestOperation * operation;
@property (nonatomic, weak, readonly) NSURLSessionDataTask * task;

@end


@implementation HNTVOperationObject

/**
 初始化
 
 @param operation 可以是AFHTTPRequestOperation或NSURLSessionDataTask
 @return self;
 */
- (instancetype)initWithOperation:(id)operation {
    self = [super init];
    if (self) {
        if ([operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            _operation = operation;
        } else if ([operation isKindOfClass:[NSURLSessionDataTask class]]) {
            _task = operation;
        }
    }
    
    return self;
}


/**
 返回请求对象AFHTTPRequestOperation或NSURLSessionDataTask
 
 @return object
 */
- (id)operationObject {
    if (self.operation) {
        return self.operation;
    }
    
    if (self.task) {
        return self.task;
    }
    return nil;
}



/**
 获得请求的URLRequest
 
 @return request
 */
- (NSURLRequest *)request {
    
    NSURLRequest * request;
    if (self.operation) {
        request = self.operation.request;
    }
    if (self.task) {
        request = self.task.originalRequest;
    }
    
    return request;
}


/**
 获得请求的NSHTTPURLResponse
 
 @return response
 */
- (NSHTTPURLResponse *)response {
    
    NSHTTPURLResponse * response;
    
    if (self.operation) {
        response = self.operation.response;
    }
    if (self.task) {
        response = (NSHTTPURLResponse*)self.task.response;
    }
    
    return response;
}


/**
 取消请求
 */
- (void)cancel {
    
    if (self.operation) {
        [self.operation cancel];
    }
    if (self.task) {
        [self.task cancel];
    }
}



/**
 暂停请求，仅支持AFNetworking2.x
 */
- (void)pause {
    if (self.operation) {
        [self.operation pause];
    }
    if (self.task) {
        [self.task suspend];
    }
}
@end
