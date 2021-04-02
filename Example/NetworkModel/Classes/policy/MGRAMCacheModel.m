//
//  MGRAMCacheModel.m
//  NetworkModel
//
//  Created by cheyongzi on 2019/12/24.
//  Copyright © 2019 Cheyongzi. All rights reserved.
//

#import "MGRAMCacheModel.h"

@implementation MGRAMCacheModel

- (BOOL)valid {
    if (!self.responseData) {
        return false;
    }
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    if (currentTime<self.expireTime) {
        return true;
    }
    return false;
}

@end
