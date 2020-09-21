//
//  WXYZ_BookReaderTopBar.h
//  WXReader
//
//  Created by Andrew on 2018/6/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXYZ_BookReaderTopBar : UIView

// 显示导航条
- (void)showNavBarCompletion:(void(^)(void))completion;

// 隐藏导航条
- (void)hiddenNavBarCompletion:(void(^)(void))completion;

@end
