//
//  WXYZ_MemberHeaderView.h
//  WXReader
//
//  Created by Andrew on 2018/7/23.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_MonthlyModel.h"
#import "YJBannerView.h"
@interface WXYZ_MemberHeaderView : UIView
@property (nonatomic, strong) NSMutableArray *bannerImageArr;
@property (nonatomic, strong) YJBannerView *bannerView;
@property (nonatomic, strong) WXYZ_MonthlyInfoModel *userModel;
@property (nonatomic, strong) NSArray <WXYZ_BannerModel *>*banner;
@property (nonatomic, copy) void (^bannerrImageClickBlock)(WXYZ_BannerModel *bannerModel);        //banner点击

@end
