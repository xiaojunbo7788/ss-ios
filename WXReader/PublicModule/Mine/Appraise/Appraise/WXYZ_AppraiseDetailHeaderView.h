//
//  WXYZ_AppraiseDetailHeaderView.h
//  WXReader
//
//  Created by Andrew on 2020/4/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_AppraiseDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AppraiseDetailHeaderView : WXYZ_BasicTableViewCell

@property (nonatomic, copy) void (^commentProductionClickBlock)(void);

@property (nonatomic, strong) WXYZ_AppraiseDetailModel *appraiseDetailModel;

@end

NS_ASSUME_NONNULL_END
