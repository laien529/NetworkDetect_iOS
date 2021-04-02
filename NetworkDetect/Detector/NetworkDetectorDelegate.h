//
//  NetworkDetectorDelegate.h
//  TestConroutine
//
//  Created by chengsc on 2021/3/16.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, NetDetectStatus) {
    NetDetectStatusWeak,
    NetDetectStatusGreat,
    NetDetectStatusNormal,
    NetDetectStatusUnknown
};

@class NetStatus;

@protocol NetworkDetectorObserverDelegate <NSObject>

@required

- (void)statusDidChanged:(NetStatus*)status;

- (void)detectTimerHeartBeat:(NSTimeInterval)interval;


@end

NS_ASSUME_NONNULL_END
