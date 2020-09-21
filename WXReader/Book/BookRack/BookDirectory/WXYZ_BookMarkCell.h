//
//  WXYZ_BookMarkCellTableViewCell.h
//  WXReader
//
//  Created by LL on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_BookMarkModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookMarkCell : UITableViewCell

@property (nonatomic, strong) WXYZ_BookMarkModel *bookMarkModel;

@end

NS_ASSUME_NONNULL_END
