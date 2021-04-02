//
//  HNTVRequestOperation+Business.m
//  ImgotvBusiness
//
//  Created by Che Yongzi on 16/6/27.
//  Copyright © 2016年 Cheyongzi. All rights reserved.
//

#import "HNTVRequestOperation+Business.h"
#import "NetworkModel.h"

@implementation HNTVRequestOperation (Business)

+ (HNTVRequestOperation*)buildOperationWithMethodString:(NSString*)methodString
                                      withOperationPath:(NSString*)operationPath
                                     withOperationParam:(NSDictionary*)paramDictionary {
    HNTVRequestOperation *operation = [[HNTVRequestOperation alloc] init];
    operation.URLString = operationPath;
    operation.method = methodString;
    operation.requestParams = paramDictionary;
    [operation setDefaultProperties];
    return operation;
}

- (void)configWithMethodString:(NSString*)methodString
             withOperationPath:(NSString*)operationPath
            withOperationParam:(NSDictionary*)paramDictionary {
    self.URLString = operationPath;
    self.method = methodString;
    self.requestParams = paramDictionary;
    [self setDefaultProperties];
}

+ (HNTVRequestOperation *)getOperationWithUrlString:(NSString *)urlString {
    HNTVRequestOperation *operation = [[HNTVRequestOperation alloc] init];
    operation.URLString = urlString;
    operation.method = @"GET";
    return operation;
}

- (void)configJSONBody:(NSDictionary *)params {
    NSMutableDictionary *mulDic = [[NetworkModel sharedModel].defaultParams mutableCopy];
    [mulDic setObject:[UserInfoResponseAccesser getUserTicket] forKey:@"ticket"];
    NSURL *requestUrl = [[NSURL URLWithString:self.URLString] URLByAppendingParameters:mulDic];
    self.URLString = requestUrl.absoluteString;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonParams = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.customHttpBody = [jsonParams dataUsingEncoding:NSUTF8StringEncoding];
    self.customRequestHeaders = @{@"Content-Type" : @"application/json"};
}

/**
 *  设置请求的公共参数
 */
- (void)setDefaultProperties {
    NSMutableDictionary *dictionary = [self.requestParams mutableCopy];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    [dictionary setObject:[UserInfoResponseAccesser getUserTicket] != nil ? [UserInfoResponseAccesser getUserTicket] : @"" forKey:@"ticket"];
    [dictionary setObject:[self getSeqId] forKey:@"seqId"];
    if (HNTV_DEVICE_NAME) {
        [dictionary setValue:HNTV_DEVICE_NAME forKey:@"dname"];
    }
    //公共参数新增海外版地区参数
    [dictionary setObject:[ApplicationConfig abroadCode]?[ApplicationConfig abroadCode]:@"" forKey:@"abroad"];
    [dictionary setObject:TeenagerModeTypeString forKey:@"ageMode"];
    //公有参数新增用户下载的版本是否是海外版版别参数
    [dictionary setObject:[ApplicationConfig getAppInternatialType]?[ApplicationConfig getAppInternatialType]:@"" forKey:@"src"];

    self.requestParams = dictionary;
    self.responseType = HNTVResponseContentTypeJson;
    self.enableCache = NO;
    self.useDefaultParams = YES;
    self.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
}

-(NSString*)getSeqId{
    NSString* openUDID = [HntvBucketUDID getUDID];
    if (openUDID) {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970]*1000;
        NSString *timeString = [NSString stringWithFormat:@"%f", a];
        NSString *seqId = [openUDID stringByAppendingString:timeString];
        return [seqId md5StringFromString];
    }
    return @"";
}

@end
