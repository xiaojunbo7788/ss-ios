//
//  WXYZ_TaskViewController.h
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_TaskViewController : WXYZ_BasicViewController

// 完成阅读作品任务
+ (void)taskReadRequestWithProduction_id:(NSInteger)production_id;

@end

NS_ASSUME_NONNULL_END
