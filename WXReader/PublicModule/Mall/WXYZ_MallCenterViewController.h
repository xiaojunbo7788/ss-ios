//
//  WXYZ_MallCenterViewController.h
//  WXReader
//
//  Created by Andrew on 2019/5/24.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_SearchView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_MallCenterViewController : WXYZ_BasicViewController

@property (nonatomic, strong) WXYZ_SearchView *searchView;
    
@property (nonatomic, strong) UIButton *sexChooseButton;
    
@property (nonatomic, assign) CGFloat contentOffsetY;

@property (nonatomic, assign) BOOL isNavDark;
@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@end

NS_ASSUME_NONNULL_END
