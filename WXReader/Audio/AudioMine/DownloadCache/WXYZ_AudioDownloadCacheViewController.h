//
//  WXYZ_AudioDownloadCacheViewController.h
//  WXReader
//
//  Created by Andrew on 2020/3/21.
//  Copyright © 2020 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioDownloadCacheViewController : WXYZ_BasicViewController

/// 切换编辑状态
@property (nonatomic, copy, readonly) BOOL (^editStateBlock)(void);

@property (nonatomic, copy) void(^changeEditStateBlock)(BOOL status);

@property (nonatomic, assign) BOOL isEditting;

@end

NS_ASSUME_NONNULL_END
