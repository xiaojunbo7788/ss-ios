//
//  WXYZ_BookMallBasicStyleTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/5/21.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_MallCenterLabelModel.h"

@interface WXYZ_BookMallBasicStyleTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) UILabel *mainTitleLabel; // 主标题

@property (nonatomic, strong) UICollectionView *mainCollectionView;

// 默认NO  与showTopRefreshButton 互斥
@property (nonatomic, assign) BOOL showTopMoreButton;

// 默认NO 与showTopMoreButton 互斥
@property (nonatomic, assign) BOOL showTopRefreshButton;

@property (nonatomic, strong) WXYZ_MallCenterLabelModel *labelModel;

@property (nonatomic, copy) void (^cellDidSelectItemBlock)(NSInteger production_id);

@property (nonatomic, copy) void (^cellSelectMoreBlock)(WXYZ_MallCenterLabelModel *labelModel);

@property (nonatomic, copy) void (^cellSelectRefreshBlock)(WXYZ_MallCenterLabelModel *labelModel, NSIndexPath *indexPath);

// 停止刷新状态
- (void)stopRefreshing;

@end
