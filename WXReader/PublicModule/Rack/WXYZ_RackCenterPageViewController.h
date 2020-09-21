//
//  WXYZ_RackCenterPageViewController.h
//  WXReader
//
//  Created by Andrew on 2020/7/1.
//  Copyright © 2020 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_RackCenterPageViewController : WXYZ_BasicViewController

@property (nonatomic, copy) void (^pushToReaderViewControllerBlock)(UIView *transitionView, WXYZ_ProductionModel *productionModel);

// 结束编辑状态
- (void)endEdited;

@end

NS_ASSUME_NONNULL_END
