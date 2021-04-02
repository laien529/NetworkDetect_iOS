//
//  ApplicationConfigReflect.h
//  NetworkModel
//
//  Created by iostiny on 28/7/2020.
//  Copyright © 2020 Cheyongzi. All rights reserved.
//

#warning 此处给出的都是一下无意义的值，仅仅为了工程能顺利跑过。具体真实值，请接入主工程，使用主工程的业务逻辑类。

#import "UserInfoResponseAccesserReflect.h"
#import "HntvBucketUDIDReflect.h"

#define TeenagerModeTypeString @"0"

NS_ASSUME_NONNULL_BEGIN

@interface ApplicationConfig : NSObject
+ (NSString *)abroadCode;
+ (NSString *)applicationType;
+ (NSString *)getAppInternatialType;
@end

NS_ASSUME_NONNULL_END
