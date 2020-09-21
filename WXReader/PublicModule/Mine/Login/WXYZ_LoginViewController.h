//
//  WXYZ_LoginViewController.h
//  WXReader
//
//  Created by Andrew on 2018/7/6.
//  Copyright © 2018年 Andrew. All rights reserved.
//


@class WXYZ_UserInfoManager;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_LoginViewController : WXYZ_BasicViewController

// 推出登录页面
+ (void)presentLoginView;

+ (void)presentLoginView:(void(^)(WXYZ_UserInfoManager *userDataModel))complete;

@end

static NSString * const kLoginViewCellIdentifier = @"kLoginViewCellIdentifier";

@interface WXYZ_LoginViewCell : UICollectionViewCell

- (void)dataInput:(NSDictionary<NSString *, UIImage *> *)dict;

@end

NS_ASSUME_NONNULL_END
