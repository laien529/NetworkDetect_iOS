//
//  SessionConfig.h
//  NetworkModel
//
//  Created by cheyongzi on 2017/12/5.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "HNTVRequestOperation.h"

@interface SessionConfig : JSONModel

@property (nonatomic, strong) NSNumber                  *useSessionTask;

@property (nonatomic, strong) NSArray<NSString*>         *blackList;

@property (nonatomic, strong) NSArray<NSString*>         *whiteList;

@property (nonatomic, strong) NSNumber         *useMetrics;

@property (nonatomic, strong) NSArray<NSString*>         *metricsAPIList;

- (BOOL)isAllowSession:(HNTVRequestOperation*)operation;

- (BOOL)isAllowMetrics:(NSURL*)url;

@end
