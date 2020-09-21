//
//  WXYZ_BannerActionManager.h
//  WXReader
//
//  Created by Andrew on 2019/6/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BannerActionManager : NSObject

+ (WXYZ_BasicViewController * _Nullable)getBannerActionWithBannerModel:(WXYZ_BannerModel *)bannerModel productionType:(WXYZ_ProductionType)productionType;

@end

NS_ASSUME_NONNULL_END
