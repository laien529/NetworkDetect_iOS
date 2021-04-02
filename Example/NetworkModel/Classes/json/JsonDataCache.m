//
//  JsonDataCache.m
//  ImgoTV-iphone
//
//  Created by yan yun on 14-2-24.
//  Copyright (c) 2014年 Hunantv. All rights reserved.
//

#import "JsonDataCache.h"
#import <CommonCrypto/CommonDigest.h>

#define JSONCACHE_MAC_CACHE_AGE 60*60*24*7

@interface JsonDataCache() {
    NSString * _cachePath;
    NSMutableDictionary * _memCache;            //内存缓存
//    NSMutableDictionary * _hashCache;           //用于比较对象是否有更新,HASH不准确暂时不用
    NSString * _name;
}

@end

@implementation JsonDataCache


+ (JsonDataCache *)singleton {
    
    static JsonDataCache * cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        cache = [[JsonDataCache alloc] initWithName:@"JSONCache"];
    });
    
    return cache;
}


- (id)initWithName:(NSString *)name {
    
    if (self = [super init]) {
        _name = name;
        [self initDirectory:name];
        [self registObserver];
        [self initMemCache];
    }
    
    
    return self;
}


- (void)initDirectory:(NSString *)name {
    
    // Init the disk cache
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:name];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
}


- (void)loadMemCache {
    
}

//初始化内存缓存
- (void)initMemCache {
    
    _memCache = [NSMutableDictionary dictionary];
//    _hashCache = [NSMutableDictionary dictionary];
    
    [self loadMemCache];
    
}


- (void)registObserver {
    // Subscribe to app events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanDisk)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
    {
        // When in background, clean memory in order to have less chance to be killed
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
#endif
}


// URL地址MD5处理
- (NSString *)cachePathForKey:(NSString *)key
{
    if(key == nil || [key length] == 0)
        return nil;
    
    const char *value = [key UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    //版本号
    if ([key hasPrefix:@"http"] && outputString.length > 0) {
        [outputString appendFormat:@".%@", HNTV_APP_VERSION];
    }
    
    return [_cachePath stringByAppendingPathComponent:outputString];
}


- (void)clear {
    
    [self clearMemory];
    [self clearDisk];
}


- (void)clearMemory {
    
     @synchronized(self) {
         [_memCache removeAllObjects];
     }
//    [_hashCache removeAllObjects];
}


//- (void)clearUserDefaults {
//    
//    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
//    NSDictionary * dict = [defs dictionaryRepresentation];
//    for (NSString * key in dict) {
//        if ([key hasPrefix:_name])
//        [defs removeObjectForKey:key];
//    }
//    [defs synchronize];
//    
//}


- (void)clearDisk {
    
    [[NSFileManager defaultManager] removeItemAtPath:_cachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}


- (void)cleanDisk
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-JSONCACHE_MAC_CACHE_AGE];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:_cachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [_cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}


- (long long)cacheSize {
    
    return [FileSizeUtils folderSizeAtPath:_cachePath];
}


- (void)clean {
    [self clearMemory];
    [self clearDisk];
}

//存储缓存的key需要将部分公共参数去掉
- (NSString*)convertCacheKey:(NSString*)key {
    NSRange range = [key rangeOfString:@"?" options:NSCaseInsensitiveSearch];
    NSURL *keyURL = [NSURL URLWithString:key];
    if (range.length != 0) {
        key = [key substringToIndex:range.location];
    }
    NSURL *convertURL = [NSURL URLWithString:key];
    NSMutableDictionary *mutableDictionary = [keyURL.parameters mutableCopy];
    [mutableDictionary removeObjectsForKeys:@[@"mac",@"osVersion",@"seqId",@"ticket"]];
    if (mutableDictionary) {
        convertURL = [convertURL URLByAppendingParameters:mutableDictionary];
    }
    if (!convertURL) {
        return key;
    }
    return convertURL.absoluteString;
}


- (BOOL)saveData:(id)data toDiskWithKey:(NSString *)key {
    NSString *convertKey = [self convertCacheKey:key];
    NSString * path = [self cachePathForKey:convertKey];
    
    //存入内存缓存
    @synchronized(self) {
        [_memCache setObject:data forKey:convertKey];
    }
    NSData * archivedData = nil;
    @try {
        archivedData = [NSKeyedArchiver archivedDataWithRootObject:data];
    }
    @catch (NSException *exception) {
        DDLogDebug(@"*** save json object exception = %@", [exception description]);
        return NO;
    }
    
    if (archivedData) {
    
        //存入本地文件
        // Can't use defaultManager another thread
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        @synchronized(self) {
            [fileManager createFileAtPath:path contents:archivedData attributes:nil];
        }
    }
    
    DDLogDebug(@"save json object to file %@", path);
    
    return archivedData != nil;
    
}


- (id)loadFromDiskWithKey:(NSString *)key {

    NSString *convertKey = [self convertCacheKey:key];
    DDLogDebug(@"%s start.key = %@", __func__, convertKey);
    
    NSString * path = [self cachePathForKey:convertKey];
    
    //从内存缓存中获取
    id data = nil;
    @autoreleasepool {
        

    @synchronized(self) {
        data = [_memCache objectForKey:convertKey];
    }

    if (!data) {
        
        //从文件中获取
        NSData * archivedData = nil;
        @synchronized(self) {
            archivedData = [NSData dataWithContentsOfFile:path];
        }
        
        if (archivedData) {
            @try {
                data = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
            }
            @catch (NSException *exception) {
                DDLogDebug(@"*** load json object exception = %@", [exception description]);
                return nil;
            }
        }
        
        
        
        //如果成功获取，存入内存缓存
        if (data) {
            @synchronized(self) {
                [_memCache setObject:data forKey:convertKey];
            }
        }
    }
    }
    
    DDLogDebug(@"%s end.key = %@", __func__, convertKey);
    
	return data;
}


//移除数据
- (void)removeFromDiskWithKey:(NSString *)key {
    NSString *convertKey = [self convertCacheKey:key];
    @synchronized(self) {
        NSString * path = [self cachePathForKey:convertKey];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]
            && [[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        [_memCache removeObjectForKey:convertKey];
    }
}


//是否存在需要更新缓存数据
- (BOOL)needUpdateCacheWithData:(id)object key:(NSString *)key {

    NSString *convertKey = [self convertCacheKey:key];
    BOOL needUpdate = NO;
    @autoreleasepool {
        
        if (!object)
            return NO;
        
        NSData * archivedData2 = nil;
        
        @try {
            archivedData2 = [NSKeyedArchiver archivedDataWithRootObject:object];
        }
        @catch (NSException *exception) {
            DDLogDebug(@"*** compare json object exception = %@", [exception description]);
        }
        
        if (!archivedData2)
            return NO;
        

        NSString * path = [self cachePathForKey:convertKey];
        
        NSData * archivedData = nil;
        @synchronized(self) {
            archivedData = [NSData dataWithContentsOfFile:path];
        }
        
        if (!archivedData)
            return YES;

        needUpdate = ![archivedData2 isEqualToData:archivedData];
    }
    
    return needUpdate;
}

@end
