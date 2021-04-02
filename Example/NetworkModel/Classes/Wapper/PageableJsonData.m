//
//  PageableJsonData.m
//  ImgotvBusiness
//
//  Created by yanyun on 16/6/29.
//  Copyright © 2016年 Cheyongzi. All rights reserved.
//

#import "PageableJsonData.h"

@interface PageableJsonData() {
    BOOL _isOver;
}
@property (nonatomic, weak) PageableJsonData<PageableJsonDataProtocol> *child;

@end

@implementation PageableJsonData

- (id)init {
    self = [super init];
    if (self && [self conformsToProtocol:@protocol(PageableJsonDataProtocol)]) {
        self.child = (PageableJsonData <PageableJsonDataProtocol> *)self;
        _isOver = NO;
        _pageCount = @(1);
        _pageSize = @(30);
    } else {
        NSException *exception = [NSException exceptionWithName:@"PageableJsonData init error" reason:@"the child class must conforms to protocol: <PageableJsonDataProtocol>" userInfo:nil];
        @throw exception;
    }
    return self;
}


+ (BOOL)propertyIsOptional:(NSString*)propertyName {

    if ([propertyName isEqualToString:@"child"]) {
        return NO;
    }
    
    return [super propertyIsOptional:propertyName];
}

+ (BOOL)propertyIsIgnored:(NSString*)propertyName {
    
    if ([propertyName isEqualToString:@"child"]) {
        return YES;
    }
    
    return [super propertyIsIgnored:propertyName];
}

- (NSInteger)currentPage {
    //_currentPage = [self datas].count / _pagesize ;
    _pageCount = [NSNumber numberWithInt:_pageCount.intValue + 1] ;
    DLog(@"%@ currentPage = %d", [self class], _pageCount.intValue);
    return _pageCount.integerValue;
}


- (NSSet*)collectKeys {
    // collect keys
    NSMutableSet* dataKeys = [[NSMutableSet alloc] init];
    for (int i = 0; i < [self.child count]; ++i) {
        id data = [[self.child datas] objectAtIndex:i];
        [dataKeys addObject:[data key]];
    }
    return dataKeys;
}

- (void)pushBack:(id<PageableJsonDataProtocol>)newDatas {
    if (!newDatas.datas || [newDatas count] == 0) {
        _isOver = YES;
        return ;
    }
    if (![self.child datas]) {
        [self.child setDatas : [newDatas datas]];
        return ;
    }
    
    //    _currentPage = [newDatas currentPage];
    
    NSSet* selfKeys = [self collectKeys];
    NSMutableArray* mutbleDatas = [[self.child datas] mutableCopy];
    for (int i = 0; i < [newDatas count]; ++i) {
        id newData = [newDatas objectAtIndex:i];
        id key = [newData key];
        if (![selfKeys containsObject:key]) {
            [mutbleDatas addObject:newData];
        }
    }
    
    [self.child setDatas:mutbleDatas];
}

- (void)pushFront:(id<PageableJsonDataProtocol>)newDatas {
    if (![newDatas datas] || [newDatas count] == 0) {
        return ;
    }
    
    if (![self.child datas]) {
        [self.child setDatas : [newDatas datas]];
        return ;
    }
    
    NSSet* selfKeys = [self collectKeys];
    NSMutableArray* mutbleDatas = [[self.child datas] mutableCopy];
    for (NSInteger i = [newDatas count] - 1; i >=0; --i) {
        id newData = [newDatas objectAtIndex:i];
        id key = [newData key];
        if (![selfKeys containsObject:key]) {
            [mutbleDatas insertObject:newData atIndex:0];
        }
    }
    
    [self.child setDatas:mutbleDatas];
}

- (BOOL)isOver {
    return _isOver;
}

- (void)setIsOver:(BOOL)isOver {
    _isOver = isOver;
}

//NSCoding 委托
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    if ((self = [super initWithCoder:aDecoder])) {
//        _pageCount = [aDecoder decodeObjectForKey:@"pageCount"];
//        _pageSize = [aDecoder decodeObjectForKey:@"pageSize"];
//    }
//    return self;
//}
//
//
////NSCoding 委托
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [super encodeWithCoder:aCoder];
//    [aCoder encodeObject:_pageCount forKey:@"pageCount"];
//    [aCoder encodeObject:_pageSize forKey:@"pageSize"];
//}


@end
