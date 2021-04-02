//
//  PassportJsonWrapper.m
//  ImgoTV-ipad
//
//  Created by Rick Shi on 22/9/2017.
//  Copyright © 2017 Hunantv. All rights reserved.
//

#import "PassportJsonWrapper.h"

@implementation PassportJsonWrapper

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"code" : @"err_code", @"msg" : @"err_msg"}];
}


@end
