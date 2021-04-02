//
//  MGDisasterModel.m
//  NetworkModel
//
//  Created by cheyongzi on 2020/11/3.
//  Copyright © 2020 Cheyongzi. All rights reserved.
//

#import "MGDisasterModel.h"

@implementation MGDisasterModel

- (MGDisasterResult)isDisaster{
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    if (currentTime - self.disassterTime < 0 || currentTime - self.disassterTime >= self.disasterDuration) {
        return MGDisasterInValid;
    }
    return MGDisasterValid;
}

@end
