//
//  HNTVRequestOperation+Business.h
//  ImgotvBusiness
//
//  Created by Che Yongzi on 16/6/27.
//  Copyright © 2016年 Cheyongzi. All rights reserved.
//

#import "NewJsonData.h"
#import "HNTVRequestOperation.h"

#define API_PATH_DEFINE(Domain,Path)\
^(){\
return [NSURL URLWithString:Path relativeToURL:[NSURL URLWithString:Domain]].absoluteString;\
}()

/**
 *  定义Operation回调的Success&Failed Block
 *
 *  @param HNTVRequestOperation 当前请求的operation
 *  @param id                   Success Response
 *  @param NSError              接口失败的错误
 */
typedef void(^HNNSuccessBlock)(HNTVRequestOperation *operation, NewJsonData *responseData);
typedef void(^HNNFailedBlock)(HNTVRequestOperation *operation, NSError *error);

@interface HNTVRequestOperation (Business)

/**
 *  Operation创建的公共方法
 *
 *  @param methodString    请求的方式，GET/POST
 *  @param operationPath   请求的路径
 *  @param paramDictionary 请求的参数
 *
 *  @return HNTVRequestOperation
 */
+ (HNTVRequestOperation*)buildOperationWithMethodString:(NSString*)methodString
                                      withOperationPath:(NSString*)operationPath
                                     withOperationParam:(NSDictionary*)paramDictionary;

/// 用于轻量级的请GET请求，比如url上报
/// @param urlString 请求URL
+ (HNTVRequestOperation *)getOperationWithUrlString:(NSString *)urlString;


/**
 *  配置的公共方法
 *
 *  @param methodString    请求的方式，GET/POST
 *  @param operationPath   请求的路径
 *  @param paramDictionary 请求的参数
 *
 */
- (void)configWithMethodString:(NSString*)methodString
             withOperationPath:(NSString*)operationPath
            withOperationParam:(NSDictionary*)paramDictionary;

/**
 请求添加Json类型的Body

 @param params 请求参数
 */
- (void)configJSONBody:(NSDictionary*)params;
@end
