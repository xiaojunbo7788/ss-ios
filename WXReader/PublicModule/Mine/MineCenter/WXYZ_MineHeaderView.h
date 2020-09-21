//
//  WXYZ_MineHeaderView.h
//  WXReader
//
//  Created by Andrew on 2018/6/20.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXYZ_UserCenterModel;

typedef void(^AvatarSelectedBlock)(void);

typedef void(^GoldSelectedBlock)(void);

typedef void(^TaskSelectedBlock)(void);

typedef void(^VoucherSelectedBlock)(void);

@interface WXYZ_MineHeaderView : UIView

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, strong) WXYZ_UserCenterModel *userModel;

@property (nonatomic, copy) AvatarSelectedBlock avatarSelectedBlock;

@property (nonatomic, copy) GoldSelectedBlock goldSelectedBlock;

@property (nonatomic, copy) TaskSelectedBlock taskSelectedBlock;

@property (nonatomic, copy) VoucherSelectedBlock voucherSelectedBlock;

@end
