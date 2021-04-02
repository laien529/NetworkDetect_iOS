//
//  PageableJsonData.h
//  ImgotvBusiness
//
//  Created by yanyun on 16/6/29.
//  Copyright © 2016年 Cheyongzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewJsonData.h"

@protocol PageableJsonDataProtocol <NSObject>
@required
- (NSArray *)datas;
- (void)setDatas:(NSArray *)datas;
- (id)objectAtIndex:(NSInteger)index;
- (NSUInteger)count;
@end

@interface PageableJsonData : NewJsonData

@property (nonatomic, weak, readonly) PageableJsonData<PageableJsonDataProtocol, Ignore> *child;

@property (nonatomic, strong) NSNumber<Optional> * pageSize;
@property (nonatomic, strong) NSNumber<Optional> * pageCount;

- (NSInteger)currentPage;
- (void)pushBack:(id<PageableJsonDataProtocol>)newDatas;
- (void)pushFront:(id<PageableJsonDataProtocol>)newDatas;
- (BOOL)isOver;
- (void)setIsOver:(BOOL)isOver;
@end
