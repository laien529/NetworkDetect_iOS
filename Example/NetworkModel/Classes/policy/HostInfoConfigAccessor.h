//
//  ApplicationConfigAccessor.h
//  ImgotvBusiness
//
//  Created by Che Yongzi on 2017/6/2.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "HostInfoConfig.h"

@interface HostInfoConfigAccessor : NSObject

/**
 保存网络重试配置信息

 @param retryInfo 重试配置信息
 */
+ (void)saveRetryInfo:(NSDictionary*)config;

/**
 获取存储的网络重试配置信息

 @return 重试配置信息
 */
+ (HostInfoConfig*)getHostInfoConfig;

@end
