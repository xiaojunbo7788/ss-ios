//
//  WXYZ_BookDownloadManagementChapterTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/4/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_BookDownloadTaskListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookDownloadManagementChapterTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_DownloadTaskModel *downloadTaskModel;

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, assign, readonly) BOOL isEditting;

/// 选择编辑单元
@property (nonatomic, copy) void(^selecteEdittingCellBlock)(WXYZ_ProductionModel *bookModel);

- (void)setEditing:(BOOL)editing;

// 强行设置编辑状态
- (void)set_Editing:(BOOL)editing;

@end

NS_ASSUME_NONNULL_END
