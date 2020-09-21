//
//  WXYZ_BookMallDetailViewController.h
//  WXReader
//
//  Created by Andrew on 2018/5/23.
//  Copyright © 2018年 Andrew. All rights reserved.
//


@interface WXYZ_BookMallDetailViewController : WXYZ_BasicViewController

@property (nonatomic, assign) NSInteger book_id;  //书籍id

/// 是不是从阅读器进入
@property (nonatomic, assign) BOOL isReader;

@end
