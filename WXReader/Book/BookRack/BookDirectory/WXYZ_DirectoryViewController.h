//
//  WXYZ_DirectoryViewController.h
//  WXReader
//
//  Created by LL on 2020/5/23.
//  Copyright © 2020 Andrew. All rights reserved.
//


@class WXYZ_ProductionModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_DirectoryViewController : WXYZ_BasicViewController

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@property (nonatomic, assign) BOOL isReader;

@property (nonatomic, copy) NSString *book_id;

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, assign) BOOL isBookDetailPush;

@end

NS_ASSUME_NONNULL_END
