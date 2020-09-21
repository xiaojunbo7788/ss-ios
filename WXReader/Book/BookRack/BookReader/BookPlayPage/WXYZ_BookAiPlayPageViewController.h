//
//  WXYZ_BookAiPlayPageViewController.h
//  WXReader
//
//  Created by Andrew on 2020/3/8.
//  Copyright © 2020 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookAiPlayPageViewController : WXYZ_BasicViewController

@property (nonatomic, assign, readonly) BOOL speaking;

@property (nonatomic, assign, readonly) BOOL stoped; // 暂停不可播放状态

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

interface_singleton

- (instancetype)init NS_UNAVAILABLE;

- (void)loadDataWithBookModel:(WXYZ_ProductionModel * __nullable)bookModel chapterModel:(WXYZ_ProductionChapterModel * __nullable)chapterModel;

@end

NS_ASSUME_NONNULL_END
