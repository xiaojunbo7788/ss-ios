//
//  WXYZ_RackCenterHeaderView.h
//  WXReader
//
//  Created by Andrew on 2019/6/13.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define Rack_Header_Height (kGeometricHeight(SCREEN_WIDTH, 3, 1) + kLabelHeight + kMargin + kQuarterMargin)

#define Rack_Header_Height_NoRecommend (kGeometricHeight(SCREEN_WIDTH, 3, 1) + kQuarterMargin)

typedef void(^RecommendBannerClickBlock)(NSInteger production_id);

typedef void(^AdBannerClickBlock)(NSString *title, NSString *content);

@interface WXYZ_RackCenterHeaderView : UIView

@property (nonatomic, assign) WXYZ_ProductionType productionType;

@property (nonatomic, strong) WXYZ_RackCenterModel *rackModel;

@property (nonatomic, copy) RecommendBannerClickBlock recommendBannerClickBlock;

@property (nonatomic, copy) AdBannerClickBlock adBannerClickBlock;

@property (nonatomic, copy) void (^collectionClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
