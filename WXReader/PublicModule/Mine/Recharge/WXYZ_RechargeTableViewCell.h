//
//  WXYZ_RechargeTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"
#import "WXYZ_RechargeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_RechargeTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_GoodsModel *goodsModel;

@property (nonatomic, assign) BOOL cellSelected;

@end

NS_ASSUME_NONNULL_END
