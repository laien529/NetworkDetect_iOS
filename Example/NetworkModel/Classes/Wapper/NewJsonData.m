//
//  NewJsonData.m
//  ImgotvBusiness
//
//  Created by Che Yongzi on 16/6/27.
//  Copyright © 2016年 Cheyongzi. All rights reserved.
//

#import "NewJsonData.h"

@interface NewJsonData ()
{
    BOOL _isFromCache;
}
@end

@implementation NewJsonData

- (BOOL)validate {
    return (_err_code.integerValue == 200);
}

- (void)setIsFromCache:(BOOL)fromCache {
    _isFromCache = fromCache;
}

- (BOOL)isFromCache {
    return _isFromCache;
}

- (BOOL)ramValidate{
    if (self.err_code.intValue == 200) {
        return true;
    }
    return false;
}

@end


@implementation MappedJsonData

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"code" : @"err_code", @"msg" : @"err_msg"}];
}

@end
