//
//  HostInfoConfig.h
//  NetworkModel
//
//  Created by Che Yongzi on 2017/8/30.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

@protocol HostInfo
@end
@interface HostInfo : JSONModel

@property (nonatomic, strong) NSString<Optional>      *host;
@property (nonatomic, strong) NSArray<Optional>       *backup;
@property (nonatomic, strong) NSString<Optional>      *master;

@end

@interface HostInfoConfig : JSONModel

@property (nonatomic, strong) NSNumber<Optional>      *retryStatus;//重试开关
@property (nonatomic, strong) NSNumber<Optional>      *mainHostTimeout;//主域名超时时间
@property (nonatomic, strong) NSNumber<Optional>      *backupHostTimeout;//重试域名超时时间
@property (nonatomic, strong) NSNumber<Optional>      *retryInterval;//重试间隔
@property (nonatomic, strong) NSNumber<Optional>      *masterStatus;//主域名替换开关
@property (nonatomic, strong) NSNumber<Optional>      *chemestatus;//模块开关
/**
 这里不需要针对多线程进行加锁的情况，因为NetworkRetryConfig信息不会修改，
 如果后期允许运行过程中修改NetworkRetryConfig的信息，则需要加锁，具体加锁可以采用dispatch barriers,
 */
@property (nonatomic, strong) NSArray<Optional,HostInfo>       *retryHosts;

/**
 根据请求判断是否存在匹配的HostInfo

 @param orignURL
 @return HostInfo
 */
- (HostInfo *)retryHost:(NSURL *)orignURL;

@end
