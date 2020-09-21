//
//  WXYZ_MemberPayTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/11/12.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_RechargeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_MemberPayTableViewCell : WXYZ_BasicTableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<WXYZ_GoodsModel *> *goodsList;

@property (nonatomic, copy) void (^selectItemBlock)(NSInteger itemIndex);

@end

NS_ASSUME_NONNULL_END
