//
//  WXYZ_MonthlyHeaderView.h
//  WXReader
//
//  Created by Andrew on 2018/6/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_MonthlyModel.h"

@interface WXYZ_MonthlyHeaderView : UIView

@property (nonatomic, copy) void (^bannerrImageClickBlock)(WXYZ_BannerModel *bannerModel);        //banner点击

@property (nonatomic, copy) void (^functionButtonClickBlock)(WXYZ_PrivilegeModel *privilegeModel);

@property (nonatomic, strong) WXYZ_MonthlyInfoModel *userInfoModel;

@property (nonatomic, strong) NSArray <WXYZ_BannerModel *>*banner;

@property (nonatomic, strong) NSArray<WXYZ_PrivilegeModel *> *privilege;

@end
