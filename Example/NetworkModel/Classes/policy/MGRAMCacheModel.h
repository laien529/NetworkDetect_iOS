//
//  MGRAMCacheModel.h
//  NetworkModel
//
//  Created by cheyongzi on 2019/12/24.
//  Copyright © 2019 Cheyongzi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Last_Modified_Key   @"Last-Modified"
#define Cache_Control_Key     @"Cache-Control"


NS_ASSUME_NONNULL_BEGIN

@interface MGRAMCacheModel : NSObject

/// 上次修改的时间点
@property (copy, nonatomic) NSString    *lastModified;

/// 过期时间
@property (assign, nonatomic) NSTimeInterval    expireTime;

/// 缓存的接口数据
@property (strong, nonatomic) id                responseData;

/// 接口缓存是否有效
@property (assign, nonatomic) BOOL              valid;

@end

NS_ASSUME_NONNULL_END
