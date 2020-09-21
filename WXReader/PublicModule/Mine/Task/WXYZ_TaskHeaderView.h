//
//  WXYZ_TaskHeaderView.h
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WXYZ_SignInfoModel;

typedef void(^SignClickBlock)(void);

@interface WXYZ_TaskHeaderView : UIView

@property (nonatomic, strong) WXYZ_SignInfoModel *signInfoModel;

@property (nonatomic, copy) SignClickBlock signClickBlock;

@end

NS_ASSUME_NONNULL_END
