//
//  WXYZ_ComicNormalVerticalCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/5/26.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_BasicComicCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

// 小图设置
#define Comic_NormalVertical_Width (SCREEN_WIDTH - 2 * Comic_Cell_Line_Space - 2 * kHalfMargin) / 3

#define Comic_NormalVertical_Height Comic_Normal_Geometric_Height(Comic_NormalVertical_Width)

#define Comic_NormalCell_Width Comic_NormalVertical_Width

#define Comic_NormalCell_Height (Comic_NormalVertical_Height + Comic_Cell_Title_Height + kHalfMargin)

@interface WXYZ_ComicNormalVerticalCollectionViewCell : WXYZ_BasicComicCollectionViewCell

@end

NS_ASSUME_NONNULL_END
