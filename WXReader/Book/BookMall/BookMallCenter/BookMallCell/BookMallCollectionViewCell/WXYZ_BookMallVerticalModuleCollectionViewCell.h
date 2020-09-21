//
//  WXYZ_BookMallVerticalModuleCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/5/21.
//  Copyright © 2018年 Andrew. All rights reserved.
//

/*
  竖直排布书籍cell
 ┌──────────────┐
 │              │
 │              │
 │              │
 │     photo    │
 │              │
 │              │
 │              │
 └──────────────┘
 ┌──────────────┐
 │   book Name  │
 └──────────────┘
 
*/

#define VerticalCellHeight (BOOK_HEIGHT + BOOK_CELL_TITLE_HEIGHT + kQuarterMargin)

#import "WXYZ_BookMallBasicModuleCollectionViewCell.h"

@interface WXYZ_BookMallVerticalModuleCollectionViewCell : WXYZ_BookMallBasicModuleCollectionViewCell

@end
