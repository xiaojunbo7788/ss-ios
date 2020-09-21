//
//  WXYZ_BookDirectoryViewController.h
//  WXReader
//
//  Created by Andrew on 2018/6/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//


@interface WXYZ_BookDirectoryViewController : WXYZ_BasicViewController

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@property (nonatomic, copy) NSString *book_id;

@property (nonatomic, assign) BOOL isBookDetailPush;

/// 是不是从阅读器进入
@property (nonatomic, assign) BOOL isReader;

- (void)orderChapter:(UIButton *)sender;

@end
