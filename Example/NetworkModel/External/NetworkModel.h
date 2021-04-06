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



@protocol NetworkModelActionDelegate <NSObject>

- (void)receiveMetricsCallBack:(id<NetworkMetrics>) metrics;

@end


@interface NetworkModel : NSObject

@property(nonatomic, weak) id<NetworkModelActionDelegate> delegate;

+ (instancetype)sharedModel;

- (void)requestWithMethod:(nonnull NSString*)method url:(nonnull NSString*)url params:(nullable NSDictionary*)params;
@end

NS_ASSUME_NONNULL_END
