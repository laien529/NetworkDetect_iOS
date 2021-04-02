//
//  DetectCache.h
//  TestConroutine
//
//  Created by chengsc on 2021/3/17.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetectCache : NSObject

+ (instancetype)sharedCache;
- (NSArray*)fetchDataByTableName:(NSString*)tableName;
- (void)insertDataToTableName:(NSString*)tableName data:(id)data;
- (void)emptyTableByName:(NSString*)tableName;

@end

NS_ASSUME_NONNULL_END
