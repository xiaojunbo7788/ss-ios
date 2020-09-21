//
//  WXYZ_ComicDownloadManagementViewController.h
//  WXReader
//
//  Created by Andrew on 2019/6/11.
//  Copyright © 2019 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicDownloadManagementViewController : WXYZ_BasicViewController

/// 切换编辑状态
@property (nonatomic, copy, readonly) BOOL (^editStateBlock)(void);

@property (nonatomic, copy) void(^changeEditStateBlock)(BOOL status);

@property (nonatomic, assign) BOOL isEditting;

@end

NS_ASSUME_NONNULL_END
