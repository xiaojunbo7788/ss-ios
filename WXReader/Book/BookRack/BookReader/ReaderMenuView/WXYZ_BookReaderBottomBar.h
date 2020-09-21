//
//  WXYZ_BookReaderBottomBar.h
//  WXReader
//
//  Created by Andrew on 2018/6/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXYZ_BookReaderBottomBar : UIView

// 正在自动阅读
@property (nonatomic, assign) BOOL autoReading;

// 显示工具栏
- (void)showToolBar;

// 隐藏工具栏
- (void)hiddenToolBar;

// 显示底部菜单按钮
- (void)showMenuView;

// 显示自动阅读栏
- (void)showAutoReadToolBar;

// 停止自动阅读
- (void)stopAutoRead;

@end
