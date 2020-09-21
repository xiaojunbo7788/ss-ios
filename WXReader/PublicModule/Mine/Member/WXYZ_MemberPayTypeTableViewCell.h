//
//  WXYZ_MemberPayTypeTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/11/12.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_RechargeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_MemberPayTypeTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_PayModel *payModel;
 
@property (nonatomic, assign) BOOL paySelected;

@end

NS_ASSUME_NONNULL_END
