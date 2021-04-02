//
//  DetectorPolicy.h
//  TestConroutine
//
//  Created by chengsc on 2021/3/17.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetectDataModel.h"
#import "NetworkDetectorDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetStatus : NSObject

@property(assign, nonatomic) NetDetectStatus netStatus;
@property(strong, nonatomic) NSNumber *httpRtt;    //ms
@property(strong, nonatomic) NSNumber *throughput; //KB per second

@end


typedef void(^DetectResultBlock)(NetStatus *status);
typedef void(^TimerHeartbeat)(NSTimeInterval interval);

@interface DetectorPolicy : NSObject

@property(nonatomic, copy) DetectResultBlock detectResultBlock;
@property(nonatomic, copy) TimerHeartbeat timerHeartbeat;

+ (instancetype)sharedPolicy;
- (void)inputOriginDatas:(DetectDataModel*)detectData;
- (void)inputHttprtt:(NSTimeInterval)httprtt;
- (void)inputThroughput_up:(float)throughput;
- (void)inputThroughput_down:(float)throughput;
- (void)startDetectTrigger;
- (void)stopDetectTrigger;
@end

NS_ASSUME_NONNULL_END
