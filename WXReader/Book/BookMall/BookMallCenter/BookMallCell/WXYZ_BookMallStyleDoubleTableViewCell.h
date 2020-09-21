//
//  WXYZ_BookMallStyleDoubleTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/5/20.
//  Copyright © 2018年 Andrew. All rights reserved.
//

/*
  双排横三排布方式
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

@interface WXYZ_BookMallStyleDoubleTableViewCell : WXYZ_BookMallBasicStyleTableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@end
