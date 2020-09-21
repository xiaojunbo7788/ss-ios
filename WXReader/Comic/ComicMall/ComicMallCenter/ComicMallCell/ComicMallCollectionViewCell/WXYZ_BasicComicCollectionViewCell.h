//
//  WXYZ_BasicComicCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/5/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ProductionCoverView.h"

NS_ASSUME_NONNULL_BEGIN

#define Comic_MaxCross_Geometric_Height(x) (((5 * x) / 9))

#define Comic_MiddleCross_Geometric_Height(x) (((2 * x) / 3))

#define Comic_Normal_Geometric_Height(x) (((4 * x) / 3))

#define Comic_Cell_Title_Height 40

#define Comic_Cell_Line_Space 3.0f

@interface WXYZ_BasicComicCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_ProductionModel *comicListModel;

@property (nonatomic, strong) WXYZ_ProductionCoverView *comicCoverView;

@property (nonatomic, strong) UILabel *comicNameLabel;

@property (nonatomic, strong) UILabel *comicDesLabel;

- (void)createSubViews;

@end

NS_ASSUME_NONNULL_END
