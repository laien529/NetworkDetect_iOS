//
//  MGCachePolicy.m
//  NetworkModel
//
//  Created by cheyongzi on 2019/12/24.
//  Copyright © 2019 Cheyongzi. All rights reserved.
//

#import "MGRAMCachePolicy.h"

@interface MGRAMCachePolicy ()

@property (strong, nonatomic) LHSafeMutableDictionary   *cacheDatas;

@property (strong, nonatomic) dispatch_queue_t          cacheQueue;

@end

@implementation MGRAMCachePolicy

- (instancetype)init {
    if (self = [super init]) {
        self.cacheDatas = [LHSafeMutableDictionary dictionary];
        self.cacheQueue = dispatch_queue_create("com.mgtv.RAM.cache.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)validResponse:(NSString *)key{
    MGRAMCacheModel *cacheModel = [self cacheModel:key];
    if ([cacheModel valid]) {
        return cacheModel.responseData;
    }
    return nil;
}

- (id)cacheResponse:(NSString *)key{
    MGRAMCacheModel *cacheModel = [self cacheModel:key];
    return cacheModel.responseData;
}

- (void)updateOperation:(HNTVRequestOperation*)operation
               response:(id)response
                    key:(NSString*)key{
    if (!response) {
        return;
    }
    NSHTTPURLResponse *urlResponse = operation.requestOperation.response;
    NSDictionary *responseHeaders = urlResponse.allHeaderFields;
    dispatch_async(self.cacheQueue, ^{
        NSString *lastModified = responseHeaders[Last_Modified_Key];
        NSString *cacheControl = [NSString stringWithFormat:@"%@",responseHeaders[Cache_Control_Key]];;
        if (!lastModified) {
            return;
        }
        MGRAMCacheModel *model = [self cacheModel:key];
        if (!model) {
            model = [MGRAMCacheModel new];
        }
        model.expireTime = [self cacheControlTime:cacheControl];
        model.lastModified = lastModified;
        model.responseData = response;
        [self.cacheDatas setObject:model forKey:key];
    });
}

- (MGRAMCacheModel *)cacheModel:(NSString *)keyPath {
    MGRAMCacheModel *model = self.cacheDatas[keyPath];
    return model;
}

- (NSTimeInterval)cacheControlTime:(NSString*)str{
    NSTimeInterval value = [[NSDate new] timeIntervalSince1970];
    if (str.length == 0 || ![str hasPrefix:@"max-age"]) {
        return 30+value;
    }
    NSArray *datas = [str componentsSeparatedByString:@"="];
    if (datas.count < 2) {
        return 30+value;
    }
    NSInteger cacheControl = [datas[1] intValue];
    return cacheControl+value;
}

- (NSString *)lastModifiedTime:(NSString *)key{
    MGRAMCacheModel *model = [self cacheModel:key];
    return model.lastModified;
}

- (void)updateExpireTime:(NSString *)key response:(NSHTTPURLResponse *)httpResponse{
    NSDictionary *responseHeaders = httpResponse.allHeaderFields;
    dispatch_async(self.cacheQueue, ^{
        NSString *lastModified = responseHeaders[Last_Modified_Key];
        NSString *cacheControl = responseHeaders[Cache_Control_Key];
        if (!lastModified) {
            return;
        }
        MGRAMCacheModel *model = [self cacheModel:key];
        if (!model) {
            return;
        }
        model.expireTime = [self cacheControlTime:cacheControl];
        model.lastModified = lastModified;
    });
}

@end
