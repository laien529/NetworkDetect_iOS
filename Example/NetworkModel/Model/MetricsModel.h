//
//  MetricsModel.h
//  TestConroutine
//
//  Created by chengsc on 2021/3/17.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetectDataProviderProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface MetricsModel : NSObject<NetworkMetrics>

@property(nonatomic, strong) NSString *domainIP;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, assign) NSTimeInterval time_DNS;
@property(nonatomic, assign) NSTimeInterval time_TCP;
@property(nonatomic, assign) NSTimeInterval time_Request;
@property(nonatomic, assign) NSTimeInterval time_HTTP;
@property(nonatomic, assign) NSTimeInterval time_Response;
@property(nonatomic, assign) NSTimeInterval taskInterval;
@property(nonatomic, assign) int64_t up_header;
@property(nonatomic, assign) int64_t up_body;
@property(nonatomic, assign) int64_t down_header;
@property(nonatomic, assign) int64_t down_body;
@property(nonatomic, assign) NSTimeInterval time_HTTPRtt;

@end

NS_ASSUME_NONNULL_END
