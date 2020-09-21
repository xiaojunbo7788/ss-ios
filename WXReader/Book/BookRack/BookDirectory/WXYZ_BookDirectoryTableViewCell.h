//
//  WXYZ_BookDirectoryTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/6/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXYZ_CatalogListModel;

@interface WXYZ_BookDirectoryTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_CatalogListModel *chapterModel;

@end
