//
//  WXYZ_CollectionViewCell.h
//  WXReader
//
//  Created by geng on 2020/9/9.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_CollectModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_CollectionViewCell : UICollectionViewCell

- (void)showInfo:(WXYZ_CollectModel *)model;

@end

NS_ASSUME_NONNULL_END
