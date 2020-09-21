//
//  WXYZ_BookMallStyleSingleTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/5/20.
//  Copyright © 2018年 Andrew. All rights reserved.
//

/*
  一排横三排布方式
 ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
 │              │   │              │   │              │
 │              │   │              │   │              │
 │              │   │              │   │              │
 │     photo    │   │     photo    │   │     photo    │
 │              │   │              │   │              │
 │              │   │              │   │              │
 │              │   │              │   │              │
 └──────────────┘   └──────────────┘   └──────────────┘
 ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
 │   book Name  │   │   book Name  │   │   book Name  │
 └──────────────┘   └──────────────┘   └──────────────┘
 
*/

#import <UIKit/UIKit.h>
#import "WXYZ_BookMallBasicStyleTableViewCell.h"

@interface WXYZ_BookMallStyleSingleTableViewCell : WXYZ_BookMallBasicStyleTableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@end
