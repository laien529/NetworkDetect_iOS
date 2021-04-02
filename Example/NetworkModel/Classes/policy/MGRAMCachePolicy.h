//
//  MGRAMCachePolicy.h
//  NetworkModel
//
//  Created by cheyongzi on 2019/12/24.
//  Copyright © 2019 Cheyongzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGRAMCacheModel.h"
#import "HNTVRequestOperation.h"

@protocol MGRAMCachePolicyProtocol <NSObject>

/// 更新某个数据的缓存到内存中
- (void)updateOperation:(HNTVRequestOperation*)operation
               response:(id)response
                    key:(NSString*)key;

/// 返回某个缓存的key有效的数据，如果无效则返回nil
- (id)validResponse:(NSString*)key;

/// 返回某个key的缓存数据，不管是否有效都会返回，
- (id)cacheResponse:(NSString*)key;

/// 根据缓存的keys获取上次修改的时间的时间
- (NSString*)lastModifiedTime:(NSString*)key;

/// 更新本地缓存的http过期时间
- (void)updateExpireTime:(NSString*)key
                response:(NSHTTPURLResponse*)httpResponse;

@end

@interface MGRAMCachePolicy : NSObject<MGRAMCachePolicyProtocol>

@end
