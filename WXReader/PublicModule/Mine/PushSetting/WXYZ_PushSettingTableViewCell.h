//
//  WXYZ_PushSettingTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/12/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_SettingBasicTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_PushSettingTableViewCell : WXYZ_SettingBasicTableViewCell

@property (nonatomic, assign) BOOL allowedPush;

@end

NS_ASSUME_NONNULL_END
