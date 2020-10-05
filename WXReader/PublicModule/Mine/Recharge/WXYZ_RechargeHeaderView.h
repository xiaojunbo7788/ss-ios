//
//  WXYZ_RechargeHeaderView.h
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_RechargeModel.h"
#import "YJBannerView.h"
NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_RechargeHeaderView : UIView

@property (nonatomic, strong) WXYZ_RechargeModel *rechargeModel;

@property (nonatomic, strong) YJBannerView *bannerView;
@property (nonatomic, strong) NSArray <WXYZ_BannerModel *>*banner;
@property (nonatomic, copy) void (^bannerrImageClickBlock)(WXYZ_BannerModel *bannerModel);        //banner点击

@end

NS_ASSUME_NONNULL_END
