//
//  NewJsonData.h
//  ImgotvBusiness
//
//  Created by Che Yongzi on 16/6/27.
//  Copyright © 2016年 Cheyongzi. All rights reserved.
//

#import "HNTVJsonModelProtocol.h"

@interface NewJsonData : JSONModel<HNTVJsonModelProtocol>

@property (nonatomic, strong) NSNumber * err_code;
@property (nonatomic, strong) NSString * err_msg;
@property (nonatomic, strong) NSString * lastRequestTime;
@property (nonatomic, strong) NSString * seqid;
@end


@interface MappedJsonData : NewJsonData

@end
