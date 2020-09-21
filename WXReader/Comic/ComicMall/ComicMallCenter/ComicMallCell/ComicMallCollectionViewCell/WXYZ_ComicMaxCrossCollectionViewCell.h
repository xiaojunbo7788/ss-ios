//
//  WXYZ_ComicMaxCrossCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/5/26.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_BasicComicCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

// 大图设置
#define Comic_MaxCross_Width (SCREEN_WIDTH - 2 * kHalfMargin)

#define Comic_MaxCross_Height Comic_MaxCross_Geometric_Height(Comic_MaxCross_Width)

#define Comic_MaxCell_Width Comic_MaxCross_Width

#define Comic_MaxCell_Height (Comic_MaxCross_Height + Comic_Cell_Title_Height + kHalfMargin)

@interface WXYZ_ComicMaxCrossCollectionViewCell : WXYZ_BasicComicCollectionViewCell

@end

NS_ASSUME_NONNULL_END
