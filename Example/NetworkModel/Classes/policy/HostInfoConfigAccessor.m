//
//  ApplicationConfigAccessor.m
//  ImgotvBusiness
//
//  Created by Che Yongzi on 2017/6/2.
//  Copyright © 2017年 Cheyongzi. All rights reserved.
//

#import "HostInfoConfigAccessor.h"

#define RetryInfo_Key @"iphone.network.retryinfo"
#define New_RetryInfo_Key @"iphone.network.retryinfo.new"

@implementation HostInfoConfigAccessor

+ (void)saveRetryInfo:(NSDictionary *)config {
    @try {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:RetryInfo_Key]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:RetryInfo_Key];
        }
        HostInfoConfig *hostInfo = [[HostInfoConfig alloc] initWithDictionary:config error:nil];
        if (!hostInfo) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:New_RetryInfo_Key];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:hostInfo] forKey:New_RetryInfo_Key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    @catch (NSException *exception) {
        
    }
}

+ (HostInfoConfig *)getHostInfoConfig {
    HostInfoConfig *retryInfo = nil;
    
    @try {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:New_RetryInfo_Key]) {
            
            id retryInfoData = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:New_RetryInfo_Key]];
            
            if ([retryInfoData isKindOfClass:[HostInfoConfig class]]) {
                HostInfoConfig *tempRetryInfo = (HostInfoConfig*)retryInfoData;
                if (tempRetryInfo) {
                    retryInfo = tempRetryInfo;
                }
            }
        }
    }
    @catch (NSException *exception) {
    }
    
    return retryInfo;
}

@end
