//
//  ApplicationConfigReflect.m
//  NetworkModel
//
//  Created by iostiny on 28/7/2020.
//  Copyright © 2020 Cheyongzi. All rights reserved.
//

#import "ApplicationConfigReflect.h"

@implementation ApplicationConfig

static NSString *s_applicationType = @"";
static NSString *s_abroadCode = @"";

#define SRC_MGTV      @"mgtv"
#define SRC_INTELMGTV @"intelmgtv"

/**
 读取abroadCode
 @return abroadCode
 */
+(NSString*)abroadCode{
    if (!s_abroadCode.length) { //第一次加载本地 localCode
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        s_abroadCode = [defaults objectForKey:@"abroadCode"];
    }
    return s_abroadCode?s_abroadCode:@"0";
}

/**
 保存abroadCode
 @param abroadCode
 */
+(void) saveAbroadCode:(NSString*)abroadCode{
    s_abroadCode = abroadCode;
    if (abroadCode) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:abroadCode forKey:@"abroadCode"];
        [defaults synchronize];
    }
}

//设置是iPhone 还是 iPad应用
+ (void)configApplicationType:(NSString *)applicationType {
    s_applicationType = applicationType;
    
}

+ (NSString *)applicationType {
    return s_applicationType;
}

/**
 *  src，值为APP版本，可扩展，mgtv-芒果TV；intelmgtv-芒果TV国际版；noah-芒果直播
 *  根据bundleId确认
 */
+ (NSString *)getAppInternatialType {
#ifdef INTERNATIONAL
    return SRC_INTELMGTV;
#endif
    return SRC_MGTV;
}

@end
