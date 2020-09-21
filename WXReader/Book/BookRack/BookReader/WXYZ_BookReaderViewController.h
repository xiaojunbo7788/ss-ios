//
//  WXYZ_BookReaderViewController.h
//  WXReader
//
//  Created by Andrew on 2018/5/29.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_ProductionModel;

@interface WXYZ_BookReaderViewController : WXYZ_BasicViewController

- (instancetype)initWithSpecificIndex:(NSInteger)specificIndex chapterSort:(NSInteger)chapterSort;

- (instancetype)initWithChapterIndex:(NSInteger)specifiedChapter;

@property (nonatomic, assign) NSInteger book_id;

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

/// 跳转到指定章节
@property (nonatomic, assign) NSInteger specifiedChapter;

/// 跳转到指定页码
@property (nonatomic, assign) NSInteger specifiedPage;

@end
 
