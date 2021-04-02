//
//  DetectorPolicy.m
//  TestConroutine
//
//  Created by chengsc on 2021/3/17.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import "DetectorPolicy.h"
#import "DetectCache.h"

@implementation NetStatus

@end

NSTimeInterval const triggerInterval = 10; //seconds 下发触发间隔
//NSTimeInterval const threshold_httprtt_weak = 1.0;
//NSTimeInterval const threshold_httprtt_great = 0.3;
//NSTimeInterval const threshold_throughput_weak = 0.2;
//NSTimeInterval const threshold_throughput_great = 2.0;

NSString* const table_httprtt = @"httprtt";
NSString* const table_throughput_down = @"Throughput_down";
NSString* const table_throughput_up = @"Throughput_up";

struct DetectResult {
    NetDetectStatus status;
    float value;
};
typedef struct DetectResult DetectResult;

@interface DetectorPolicy () {
    NSTimer *triggerTimer;
    
    NSTimeInterval threshold_httprtt_weak;
    NSTimeInterval threshold_httprtt_great;
    NSTimeInterval threshold_throughput_weak;
    NSTimeInterval threshold_throughput_great;
}

@end

@implementation DetectorPolicy

+ (instancetype)sharedPolicy {
    static dispatch_once_t onceToken;
    static DetectorPolicy *policy;
    dispatch_once(&onceToken, ^{
        policy = [[DetectorPolicy alloc] init];
    });
    return policy;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)startDetectTrigger {
    __block NSTimeInterval interval = 1;
    __weak typeof(self) weakSelf = self;
    triggerTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (interval == triggerInterval) {
            [weakSelf judgeNetworkStatus];
            interval = 1;
        } else {
            interval++;
        }
        if (weakSelf.timerHeartbeat) {
            weakSelf.timerHeartbeat(interval);
        }
    }];
    [triggerTimer fire];
}

- (void)stopDetectTrigger {
    [triggerTimer invalidate];
}

- (void)judgeNetworkStatus {
    NSString *WeakHttpThreshold = [[NSUserDefaults standardUserDefaults] objectForKey:@"WeakHttpThreshold"];
    NSString *GreatHttpThreshold = [[NSUserDefaults standardUserDefaults] objectForKey:@"GreatHttpThreshold"];
    NSString *WeakThroughputThreshold = [[NSUserDefaults standardUserDefaults] objectForKey:@"WeakThroughputThreshold"];
    NSString *GreatThroughputThreshold = [[NSUserDefaults standardUserDefaults] objectForKey:@"GreatThroughputThreshold"];
    threshold_httprtt_weak = WeakHttpThreshold.floatValue / 1000;
    threshold_httprtt_great = GreatHttpThreshold.floatValue / 1000;
    threshold_throughput_weak = WeakThroughputThreshold.floatValue;
    threshold_throughput_great = GreatThroughputThreshold.floatValue;

    if (_detectResultBlock) {
        
        NetStatus *status = [[NetStatus alloc] init];
        NetDetectStatus judgedStatus = NetDetectStatusUnknown;

        DetectResult httprttResult = [self detectHttprtt];
        NetDetectStatus httprttStatus = httprttResult.status;
        
        DetectResult throughputResult = [self detectThroughtput_down];
        NetDetectStatus throughput_downStatus = throughputResult.status;
        
        if (httprttStatus == NetDetectStatusGreat && throughput_downStatus == NetDetectStatusGreat) {
            judgedStatus = NetDetectStatusGreat;
        } else if (httprttStatus == NetDetectStatusWeak && throughput_downStatus == NetDetectStatusWeak) {
            judgedStatus = NetDetectStatusWeak;
        } else if (httprttStatus == NetDetectStatusUnknown || throughput_downStatus == NetDetectStatusUnknown){
            judgedStatus = NetDetectStatusUnknown;
        } else {
            judgedStatus = NetDetectStatusNormal;
        }
        status.netStatus = judgedStatus;
        status.httpRtt = @(httprttResult.value);
        status.throughput = @(throughputResult.value);
        _detectResultBlock(status);
        
        NSLog(@"judgeNetworkStatus %lu",(unsigned long)judgedStatus);
    }
}

- (DetectResult)detectHttprtt {
    NSArray *httprttArray = [[DetectCache sharedCache] fetchDataByTableName:table_httprtt];
    if (httprttArray.count > 0) {
        
        float avgHttprtt = [[httprttArray valueForKeyPath:@"@avg.floatValue"] floatValue];
        NetDetectStatus status = [self statusFromHttprttJudge:avgHttprtt];
        DetectResult _result = {status, avgHttprtt};
        return _result;
    }
    return (DetectResult){NetDetectStatusUnknown, 0.0};
}

- (DetectResult)detectThroughtput_down {
    NSArray *throughputArray = [[DetectCache sharedCache] fetchDataByTableName:table_throughput_down];
    if (throughputArray.count > 0) {
        float avgThroughput = [[throughputArray valueForKeyPath:@"@avg.floatValue"] floatValue];

        NetDetectStatus status = [self statusFromThroughputJudge:avgThroughput];
        DetectResult _result = {status, avgThroughput};

        return _result;
    }
    return (DetectResult){NetDetectStatusUnknown, 0.0};
}

- (NetDetectStatus)statusFromHttprttJudge:(float)httprtt {
//    if (httprtt == 0) {
//        return NetDetectStatusUnknown;
//    }
    if (httprtt <= threshold_httprtt_great) {
        return NetDetectStatusGreat;
    } else if (httprtt >= threshold_httprtt_weak) {
        return NetDetectStatusWeak;
    } else {
        return NetDetectStatusNormal;
    }
}

- (NetDetectStatus)statusFromThroughputJudge:(float)throughput {
    if (throughput == 0) {
        return NetDetectStatusUnknown;
    }
    if (throughput >= threshold_throughput_great) {
        return NetDetectStatusGreat;
    } else if (throughput <= threshold_throughput_weak) {
        return NetDetectStatusWeak;
    } else {
        return NetDetectStatusNormal;
    }
}

- (void)inputHttprtt:(NSTimeInterval)httprtt {
    [[DetectCache sharedCache] insertDataToTableName:table_httprtt data:@(httprtt)];
}

- (void)inputThroughput_up:(float)throughput {
    [[DetectCache sharedCache] insertDataToTableName:table_throughput_up data:@(throughput)];
}

- (void)inputThroughput_down:(float)throughput {
    [[DetectCache sharedCache] insertDataToTableName:table_throughput_down data:@(throughput)];
}

- (void)inputOriginDatas:(DetectDataModel *)detectData {}

@end
