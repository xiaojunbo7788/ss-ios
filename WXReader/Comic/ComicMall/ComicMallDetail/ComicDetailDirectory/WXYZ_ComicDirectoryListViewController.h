//
//  WXYZ_ComicDirectoryListViewController.h
//  WXReader
//
//  Created by Andrew on 2019/5/29.
//  Copyright © 2019 Andrew. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicDirectoryListViewController : WXYZ_BasicViewController

@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, assign) CGFloat contentOffSetY;

@property (nonatomic, strong) WXYZ_ProductionModel *comicModel;

@end

NS_ASSUME_NONNULL_END
