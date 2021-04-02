//
//  HNTVJsonModelProtocol.h
//  NetworkModel
//
//  Created by yanyun on 15/4/30.
//  Copyright (c) 2015年 com.hunantv. All rights reserved.
//

#ifndef NetworkModel_HNTVJsonModelProtocol_h
#define NetworkModel_HNTVJsonModelProtocol_h

@protocol HNTVJsonModelProtocol <NSObject>



@required
/**
 *  有效性检测
 *
 *  @return 有效性结果
 */
- (BOOL)validate;
/**
 *  设置是否来源于本地缓存
 *
 *  @param fromCache 是否来源于本地缓存
 */
- (void)setIsFromCache:(BOOL)fromCache;
/**
 *  是否来源于本地缓存
 *
 *  @return 是否来源于本地缓存
 */
- (BOOL)isFromCache;

/// 是否可以将接口数据同步到RAM缓存
- (BOOL)ramValidate;

@end

#endif
