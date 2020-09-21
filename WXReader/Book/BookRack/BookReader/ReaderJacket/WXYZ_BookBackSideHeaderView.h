//
//  WXYZ_BookBackSideHeaderView.h
//  WXReader
//
//  Created by Andrew on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_BookBackSideModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookBackSideHeaderView : UIView

@property (nonatomic, copy) void (^commentClickBlock)(void);

@property (nonatomic, strong) WXYZ_BookBackSideModel *headerModel;

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@end

NS_ASSUME_NONNULL_END
