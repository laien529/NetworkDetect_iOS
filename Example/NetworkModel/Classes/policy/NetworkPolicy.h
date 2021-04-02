//
//  NetworkPolicy.h
//  NetworkModel
//
//  Created by Che Yongzi on 2017/8/31.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//
#import "HNTVRequestOperation.h"
#import "NetworkHostPolicy.h"
#import "NetwokRetryPolicy.h"

#define MGRequestReportTypeKey @"kMGRequestReportType"

typedef void(^RetryRequestBlock)(void);

@protocol NetworkPolicyProtocol <NSObject>

@required

/**
 根据config接口下发的数据，生成对象

 @param data 数据
 @return instance
 */
- (id)initWithData:(id)data;

/**
 更新策略

 @param data HostInfoConfig
 */
- (void)updatePolicy:(id)data;

/**
 根据策略模块重新配置请求

 @param operation HNTVRequestOperation
 @param error 接口失败错误原因
 */
- (BOOL)configOperation:(HNTVRequestOperation*)operation
                  error:(NSError*)error;

/**
 发起重试域名请求
 
 @param retryBlock 重试需要执行的block
 */
- (void)startRetryRequest:(RetryRequestBlock)retryBlock;

/**
 失败之后更新重试信息

 @param operation HNTVRequestOperation
 @param error 错误信息
 @param isEnd 重试流程是否完全结束
 */
- (void)updateRetryInfo:(HNTVRequestOperation *)operation
                  error:(NSError *)error
                  isEnd:(BOOL)isEnd;

@optional

/*
 接口是否在容灾策略内
 BOOL：true标识接口再容灾策略内，false标识接口不在容灾策略内
 */
- (BOOL)inDisasterRequest:(HNTVRequestOperation*)operation;

/*
 更新容灾域名逻辑
 BOOL：域名是否在符合容灾行为，true标识该域名需要容灾，不进行重试，false标识可以继续进行后续操作
 */
- (BOOL)disasterRequest:(HNTVRequestOperation*)operation
               response:(NSHTTPURLResponse*)response;

/// 503容灾逻辑开关
@property (assign, nonatomic) NSInteger     disasterConfig;

@end

@interface NetworkPolicy : NSObject<NetworkPolicyProtocol>

@end

//上报
typedef NS_ENUM(NSUInteger, MGRequestReportType) {
    MGRequestReportTypeUnknown,
    MGRequestReportTypeUMeng,
};

typedef NS_ENUM(NSUInteger, MGRequestStatus) {
    MGRequestStart,
    MGRequestComplete,
};

@protocol MGRequsetReportPolicyProtocol <NSObject>

/// 回调上层数据
- (void)requestOperation:(HNTVRequestOperation*)operation
                  status:(MGRequestStatus)status
                response:(nullable id)response;

@end



@interface MGRequsetReportPolicy : NSObject

@property (nonatomic, weak) id<MGRequsetReportPolicyProtocol> delegate;

@end
