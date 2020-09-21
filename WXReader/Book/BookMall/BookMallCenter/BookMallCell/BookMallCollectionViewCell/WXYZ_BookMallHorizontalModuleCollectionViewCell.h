//
//  WXYZ_BookMallHorizontalModuleCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/5/22.
//  Copyright © 2018年 Andrew. All rights reserved.
//

/*
  横排布书籍cell
 ┌──────────────┐  ┌────────────────────────┐
 │              │  │       book Name        │
 │              │  └────────────────────────┘
 │              │  ┌────────────────────────┐
 │     photo    │  │                        │
 │              │  │        describe        │
 │              │  │                        │
 │              │  │                        │
 └──────────────┘  └────────────────────────┘
*/

#define HorizontalCellHeight (kGeometricHeight(BOOK_WIDTH - 10, 3, 4) + kHalfMargin)

#import "WXYZ_BookMallBasicModuleCollectionViewCell.h"

@interface WXYZ_BookMallHorizontalModuleCollectionViewCell : WXYZ_BookMallBasicModuleCollectionViewCell

@end
