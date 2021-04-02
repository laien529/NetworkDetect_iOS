//
//  NetDetector.h
//  TestConroutine
//
//  Created by chengsc on 2021/3/16.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetectDataProviderProtocol.h"
#import "DetectorPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetDetector : NSObject

@property(nonatomic, weak)id<NetworkDetectorObserverDelegate> observer;
@property(nonatomic, weak)id<DetectDataProviderProtocol> dataProvider;

+ (instancetype)sharedDetector;
- (void)registService:(id)observer;

@end

NS_ASSUME_NONNULL_END
