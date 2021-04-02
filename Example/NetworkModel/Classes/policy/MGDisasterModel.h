//
//  MGDisasterModel.h
//  NetworkModel
//
//  Created by cheyongzi on 2020/11/3.
//  Copyright © 2020 Cheyongzi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MGDisasterValid,/// 存在匹配的容灾策略
    MGDisasterInValid,/// 匹配的容灾策略已过期
} MGDisasterResult;

NS_ASSUME_NONNULL_BEGIN

@interface MGDisasterModel : NSObject

/// 容灾域名
@property (copy, nonatomic) NSString        *host;

/// 发生容灾的时间戳
@property (assign, nonatomic) NSTimeInterval    disassterTime;

/// 容灾时长，默认不超过5分钟
@property (assign, nonatomic) NSInteger     disasterDuration;

/*
 根据域名判断是否符合容灾策略
 MGDisasterResult: 详见枚举值
 */
- (MGDisasterResult)isDisaster;

@end

NS_ASSUME_NONNULL_END
