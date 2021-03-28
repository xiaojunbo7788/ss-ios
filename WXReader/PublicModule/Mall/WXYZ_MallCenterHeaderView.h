//
//  WXYZ_MallCenterHeaderView.h
//  WXReader
//
//  Created by Andrew on 2019/5/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUMarqueeView.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_MenuButtonType) {
    WXYZ_MenuButtonTypeFree,     // 免费
    WXYZ_MenuButtonTypeFinish,   // 完结
    WXYZ_MenuButtonTypeClass,    // 分类
    WXYZ_MenuButtonTypeRank,     // 排行
    WXYZ_MenuButtonTypeMember    // 会员
};

typedef void(^BannerrImageClickBlock)(WXYZ_BannerModel *bannerModel);

@interface WXYZ_MallCenterHeaderView : UIView

@property (nonatomic, assign) WXYZ_ProductionType productionType;

@property (nonatomic, strong) WXYZ_MallCenterModel *mallCenterModel;

@property (nonatomic, strong) UUMarqueeView *upwardMultiMarqueeView;

@property (nonatomic, copy) void (^menuButtonClickBlock)(WXYZ_MenuButtonType menuButtonType, NSString *menuButtonTitle);

@property (nonatomic, copy) void(^bannerrImageClickBlock)(WXYZ_BannerModel *bannerModel);      //banner点击

- (void)createSubViews;

@end

NS_ASSUME_NONNULL_END
