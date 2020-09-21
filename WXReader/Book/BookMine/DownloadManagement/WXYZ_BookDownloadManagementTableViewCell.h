//
//  WXYZ_BookDownloadManagementTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/4/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_BookDownloadTaskListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OpenBookBlock)(NSString *book_id);

typedef void(^CellSelectBlock)(NSInteger production_id);

@interface WXYZ_BookDownloadManagementTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, copy) CellSelectBlock cellSelectBlock;

@property (nonatomic, strong) WXYZ_ProductionModel *productionModel;

@property (nonatomic, copy) OpenBookBlock openBookBlock;

@property (nonatomic, strong) UIButton *openBook;

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
