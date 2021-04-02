//
//  HNTVOperationObject.h
//  NetworkModel
//
//  Created by yanyun on 2017/3/31.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//
//  外观模式 封装AFHTTPRequestOperation 和 NSURLSessionDataTask


#import <Foundation/Foundation.h>

/**
 获取请求相关信息协议
 */
@protocol HNTVOperationable <NSObject>


/**
 返回请求对象AFHTTPRequestOperation或NSURLSessionDataTask

 @return object
 */
- (id)operationObject;

/**
 获得请求的URLRequest
 
 @return request
 */
- (NSURLRequest *)request;


/**
 获得请求的NSHTTPURLResponse
 
 @return response
 */
- (NSHTTPURLResponse *)response;


/**
 取消请求
 */
- (void)cancel;



/**
 暂停请求，仅支持AFNetworking2.x
 */
- (void)pause;

@end


@interface HNTVOperationObject : NSObject<HNTVOperationable>


/**
 初始化

 @param operation 可以是AFHTTPRequestOperation或NSURLSessionDataTask
 @return self;
 */
- (instancetype)initWithOperation:(id)operation;

@end
