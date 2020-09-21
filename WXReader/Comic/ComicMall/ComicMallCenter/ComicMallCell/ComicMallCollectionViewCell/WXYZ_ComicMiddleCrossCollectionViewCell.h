//
//  WXYZ_ComicMiddleCrossCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/5/26.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_BasicComicCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

// 中图设置
#define Comic_MiddleCross_Width (SCREEN_WIDTH - Comic_Cell_Line_Space - 2 * kHalfMargin) / 2

#define Comic_MiddleCross_Height Comic_MiddleCross_Geometric_Height(Comic_MiddleCross_Width)

#define Comic_MiddleCell_Width Comic_MiddleCross_Width

#define Comic_MiddleCell_Height (Comic_MiddleCross_Height + Comic_Cell_Title_Height + kHalfMargin)

@interface WXYZ_ComicMiddleCrossCollectionViewCell : WXYZ_BasicComicCollectionViewCell

@end

NS_ASSUME_NONNULL_END
