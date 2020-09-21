//
//  WXYZ_BookMallStyleMixtureMoreTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/6/14.
//  Copyright © 2019 Andrew. All rights reserved.
//

/*
  横一竖三排布方式
 ┌──────────────┐  ┌──────────────────────────────────┐
 │              │  │              book Name           │
 │              │  └──────────────────────────────────┘
 │              │  ┌──────────────────────────────────┐
 │     photo    │  │                                  │
 │              │  │              describe            │
 │              │  │                                  │
 │              │  │                                  │
 └──────────────┘  └──────────────────────────────────┘
 
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

#import "WXYZ_BookMallBasicStyleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookMallStyleMixtureMoreTableViewCell : WXYZ_BookMallBasicStyleTableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@end

NS_ASSUME_NONNULL_END
