//
//  NetworkModel.h
//  TestConroutine
//
//  Created by chengsc on 2021/3/16.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetricsModel.h"
NS_ASSUME_NONNULL_BEGIN


typedef void(^MetricsBlock)(MetricsModel* metrics);


@interface NetworkModel : NSObject

@property(nonatomic, copy) MetricsBlock metricsBlock;

+ (instancetype)sharedModel;

- (void)requestWithMethod:(nonnull NSString*)method url:(nonnull NSString*)url params:(nullable NSDictionary*)params;
@end

NS_ASSUME_NONNULL_END
