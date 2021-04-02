//
//  DetectDataModel.h
//  TestConroutine
//
//  Created by chengsc on 2021/3/17.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetectDataModel : NSObject

@property(nonatomic, assign) NSTimeInterval batch_httprtt;
@property(nonatomic, assign) int64_t up_thp;
@property(nonatomic, assign) int64_t down_thp;

@end

NS_ASSUME_NONNULL_END
