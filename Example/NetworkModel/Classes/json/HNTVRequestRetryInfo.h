//
//  HNTVRequestRetryInfo.h
//  NetworkModel
//
//  Created by Che Yongzi on 2016/12/27.
//  Copyright © 2016年 Cheyongzi. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 接口失败信息
 B、failedRequest:表示失败的请求
 C、error:表示失败的请求错误信息
 */
@interface HNTVRequestFailedInfo : NSObject<NSCopying>

@property (nonatomic, strong) NSURLRequest             *failedRequest;
@property (nonatomic, strong) NSString                 *httpCode;
@property (nonatomic, strong) NSError                  *error;

@end


/** 接口重试请求的详细信息，主要用于应用层获取重试的信息
 A、requestCount:表示接口重试的次数
 B、failedInfos:表示接口重试失败信息
 C、successRequest:表示成功的URLRequest
 */
@interface HNTVRequestRetryInfo : NSObject<NSCopying>

@property (nonatomic, assign) NSInteger                retryCount;
@property (nonatomic, strong) NSMutableArray           *failedInfos;
@property (nonatomic, strong) NSURLRequest             *successRequest;

@end
