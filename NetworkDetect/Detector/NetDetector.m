//
//  NetDetector.m
//  TestConroutine
//
//  Created by chengsc on 2021/3/16.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import "NetDetector.h"

NSString * const serviceName = @"NetworkDetect";
NSInteger BatchSize = 5;

@interface NetDetector () {
    NSMutableDictionary *observersMap;
    NSMutableArray *thp_batch;
}

@end

@implementation NetDetector

+ (instancetype)sharedDetector {
    static dispatch_once_t onceToken;
    static NetDetector *detector;
    dispatch_once(&onceToken, ^{
        detector = [[NetDetector alloc] init];
    });
    return detector;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        observersMap = [[NSMutableDictionary alloc] init];
        thp_batch = [[NSMutableArray alloc] init];
        __weak typeof(self) weakSelf = self;
        [self.dataProvider setupMetricsCallBack:^(id<NetworkMetrics> _Nonnull metrics) {
            [weakSelf preprocessInputs:metrics];
        }];
        [[DetectorPolicy sharedPolicy] setTimerHeartbeat:^(NSTimeInterval interval) {
            [weakSelf.observer detectTimerHeartBeat:interval];
        }];
        [[DetectorPolicy sharedPolicy] setDetectResultBlock:^(NetStatus *status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.observer statusDidChanged:status];
            });
        }];
        [[DetectorPolicy sharedPolicy] startDetectTrigger];
    }
    return self;
}

- (void)inputMetricsData:(id<NetworkMetrics>)metrics {
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:serviceName object:metrics];
}

- (void)registService:(id)observer {
    self.observer = observer;
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(statusDidChanged:) name:serviceName object:nil];
    [observersMap setObject:observer forKey:NSStringFromClass(observersMap.class)];
}

- (void)processThroughputData:(float *)batch_down_tp batch_up_tp:(float *)batch_up_tp {
    __block int64_t batch_down_bytes = 0;
    __block int64_t batch_up_bytes = 0;
    __block NSTimeInterval batch_down_interval = 0;
    __block NSTimeInterval batch_up_interval = 0;
    
    [thp_batch enumerateObjectsUsingBlock:^(id<NetworkMetrics>_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        batch_down_bytes += obj.down_header;
        batch_down_bytes += obj.down_body;
        batch_down_interval += obj.time_Response;
        
        batch_up_bytes += obj.up_header;
        batch_up_bytes += obj.up_body;
        batch_up_interval += obj.time_Request;
        
    }];
    *batch_down_tp = batch_down_interval == 0 ? 0 : batch_down_bytes / (1024 * 1024 * batch_down_interval);
    *batch_up_tp = batch_up_interval == 0 ? 0 :batch_up_bytes / (1024 * 1024 * batch_up_interval);
}

- (void)preprocessInputs:(id<NetworkMetrics>)metrics {
    
    [thp_batch addObject:metrics];
    
    if (metrics.time_HTTPRtt > 0 ) {
        [[DetectorPolicy sharedPolicy] inputHttprtt:metrics.time_HTTPRtt];

    }
    if (thp_batch.count >= BatchSize) { //吞吐量批量处理
        
        float batch_down_tp = 0;
        float batch_up_tp = 0;
        
        [self processThroughputData:&batch_down_tp batch_up_tp:&batch_up_tp];
        
//        [[DetectorPolicy sharedPolicy] inputThroughput_up:batch_up_tp];
        [[DetectorPolicy sharedPolicy] inputThroughput_down:batch_down_tp];
        [thp_batch removeAllObjects];
    }
}

@end
