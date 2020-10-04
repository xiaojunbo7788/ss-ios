//
//  WXYZ_InviteTopBgView.h
//  WXReader
//
//  Created by geng on 2020/10/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ShareModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_InviteTopBgView : UIView

@property (nonatomic, copy) void(^onClick)();

- (void)showInfo:(WXYZ_ShareModel *)model;

@end

NS_ASSUME_NONNULL_END
