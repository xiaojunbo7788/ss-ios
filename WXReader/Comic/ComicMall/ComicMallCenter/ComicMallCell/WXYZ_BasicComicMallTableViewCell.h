//
//  WXYZ_BasicComicMallTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/5/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_MallCenterLabelModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CellDidSelectItemBlock)(NSInteger production_id);

typedef void (^CellSelectMoreBlock)(WXYZ_MallCenterLabelModel *labelModel);

@interface WXYZ_BasicComicMallTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) UILabel *mainTitleLabel; // 主标题

@property (nonatomic, strong) UICollectionView *mainCollectionView;

@property (nonatomic, assign) BOOL showTopMoreButton;

@property (nonatomic, strong) WXYZ_MallCenterLabelModel *labelModel;

@property (nonatomic, copy) CellDidSelectItemBlock cellDidSelectItemBlock;

@property (nonatomic, copy) CellSelectMoreBlock cellSelectMoreBlock;

@end

NS_ASSUME_NONNULL_END
