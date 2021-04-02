//
//  PolicyProtocol.h
//  NetworkModel
//
//  Created by Che Yongzi on 2017/8/31.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "HostInfoConfig.h"
#import "HNTVRequestOperation.h"

@protocol HNTVPolicyProtocol <NSObject>

@required
/**
 策略协议，判断是否存在可执行的策略，如果有就替换operation中的某些属性,返回YES，否则就返回NO
 
 @param operation HNTVRequestOperation
 @return BOOL
 */
- (BOOL)configOperation:(HNTVRequestOperation*)operation;

/**
 根据HostInfoConfig生成对应的策略

 @param config
 @return instance
 */
- (id)initWithConfig:(HostInfoConfig*)config;

@end
