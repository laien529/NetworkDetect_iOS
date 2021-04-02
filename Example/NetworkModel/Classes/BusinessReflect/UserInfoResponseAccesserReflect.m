//
//  UserInfoResponseAccesserReflect.m
//  NetworkModel
//
//  Created by iostiny on 29/7/2020.
//  Copyright © 2020 Cheyongzi. All rights reserved.
//

#import "UserInfoResponseAccesserReflect.h"

@implementation UserInfoResponseAccesser
// 在本地获取ticket
// 需要兼容处理，防止ticket丢失;
+ (NSString *)getUserTicket {
    NSString *userTicket = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.userticket.passport", [ApplicationConfig applicationType]]];
    if (userTicket && userTicket.length) {
        return userTicket;
    }
    return @"";
}

@end
