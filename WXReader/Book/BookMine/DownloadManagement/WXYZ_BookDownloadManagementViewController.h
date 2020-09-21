//
//  WXYZ_BookDownloadManagementViewController.h
//  WXReader
//
//  Created by Andrew on 2019/4/3.
//  Copyright © 2019 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookDownloadManagementViewController : WXYZ_BasicViewController

@property (nonatomic, assign) BOOL pushFromReader;

@property (nonatomic, assign) BOOL isEditting;

/// 切换编辑状态
@property (nonatomic, copy, readonly) BOOL (^editStateBlock)(void);

@property (nonatomic, copy) void(^changeEditStateBlock)(BOOL status);

@end

NS_ASSUME_NONNULL_END
