//
//  WXYZ_AudioDownloadCacheTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/4/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CellSelectBlock)(WXYZ_ProductionModel *productionModel, NSInteger production_id, NSString *name);

typedef void(^ImageViewSelectBlock)(NSInteger production_id);

typedef void(^ButtonSelectBlock)(WXYZ_ProductionModel *productionModel);

@interface WXYZ_AudioDownloadCacheTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_ProductionModel *productionModel;

@property (nonatomic, copy) CellSelectBlock cellSelectBlock;

@property (nonatomic, copy) ImageViewSelectBlock imageViewSelectBlock;

@property (nonatomic, copy) ButtonSelectBlock buttonSelectBlock;

@property (nonatomic, assign, readonly) BOOL isEditting;

@property (nonatomic, assign, readonly) BOOL isSelected;

/// 选择编辑单元
@property (nonatomic, copy) void(^selecteEdittingCellBlock)(WXYZ_ProductionModel *productionModel, BOOL isSelected);

- (void)setEditing:(BOOL)editing;

// 强行设置编辑状态
- (void)set_Editting:(BOOL)editting;

// 切换选中状态
- (void)switchSelectedState:(BOOL)state;

@end

NS_ASSUME_NONNULL_END
