//
//  WXYZ_MonthlyModel.h
//  WXReader
//
//  Created by Andrew on 2018/6/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXYZ_MemeberModel.h"
#import "WXYZ_MallCenterLabelModel.h"

@class WXYZ_MonthlyInfoModel;

@interface WXYZ_MonthlyModel : NSObject

@property (nonatomic, strong) WXYZ_MonthlyInfoModel *user;

@property (nonatomic, strong) NSArray<WXYZ_PrivilegeModel *> *privilege;

@property (nonatomic, strong) NSArray <WXYZ_BannerModel *>*banner;

@property (nonatomic, strong) NSArray<WXYZ_MallCenterLabelModel *> *label;  //推荐作品label

@end

@interface WXYZ_MonthlyInfoModel : NSObject

@property (nonatomic, copy) NSString *nickname;         // 昵称

@property (nonatomic, copy) NSString *avatar;           // 头像

@property (nonatomic, assign) NSInteger baoyue_status;  // 包月状态 0未开通包月 1已开通包月

@property (nonatomic, copy) NSString *expiry_date;      // 包月有效期

@property (nonatomic, copy) NSString *vip_desc;

@end
