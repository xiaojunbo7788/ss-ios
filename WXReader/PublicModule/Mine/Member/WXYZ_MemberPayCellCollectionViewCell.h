//
//  WXYZ_MemberPayCellCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_RechargeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_MemberPayCellCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_GoodsModel *goodsModel;

@property (nonatomic, assign) BOOL cellSelected;

@end

NS_ASSUME_NONNULL_END
