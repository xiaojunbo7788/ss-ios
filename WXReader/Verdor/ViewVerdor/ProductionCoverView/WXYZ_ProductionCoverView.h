//
//  WXYZ_ProductionCoverView.h
//  WXReader
//
//  Created by Andrew on 2020/7/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_ProductionCoverDirection) {
    WXYZ_ProductionCoverDirectionVertical,   // 竖直方向
    WXYZ_ProductionCoverDirectionHorizontal  // 水平方向
};

@interface WXYZ_ProductionCoverView : UIView

// 封面图片地址
@property (nonatomic, copy) NSString *coverImageURL;

// 封面底部标题
@property (nonatomic, copy) NSString *coverTitleString;

// 是否是付费样式
@property (nonatomic, assign) BOOL is_locked;

// 作品类型
@property (nonatomic, assign) WXYZ_ProductionType productionType;

// 图片展示方向
@property (nonatomic, assign) WXYZ_ProductionCoverDirection productionCoverDirection;

/* 初始化
 
 @param productionType 作品类型
 @param productionCoverDirection 图片展示方向
 **/

- (instancetype)initWithProductionType:(WXYZ_ProductionType)productionType productionCoverDirection:(WXYZ_ProductionCoverDirection)productionCoverDirection;

// 重置为默认图
- (void)resetDefaultHoldImage;

@end

NS_ASSUME_NONNULL_END
