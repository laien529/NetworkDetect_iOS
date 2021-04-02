//
//  JsonDataCache.h
//  ImgoTV-iphone
//
//  Created by yan yun on 14-2-24.
//  Copyright (c) 2014年 Hunantv. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Json 本地存储
 */
@interface JsonDataCache : NSObject

+ (JsonDataCache *)singleton;
- (void)clear;

//存入数据
- (BOOL)saveData:(id)data toDiskWithKey:(NSString *)key;
//读取数据
- (id)loadFromDiskWithKey:(NSString *)key;
//移除数据
- (void)removeFromDiskWithKey:(NSString *)key;
//是否存在相同的数据
- (BOOL)needUpdateCacheWithData:(id)object key:(NSString *)key;
//缓存大小
- (long long)cacheSize;
//清理缓存
- (void)clean;
@end
