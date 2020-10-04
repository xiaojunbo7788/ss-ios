//
//  WXYZ_InviteTopTableViewCell.h
//  WXReader
//
//  Created by geng on 2020/10/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ShareModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_InviteTopTableViewCellDelegate <NSObject>

- (void)onBindUser;
- (void)onShare;

@end

@interface WXYZ_InviteTopTableViewCell : UITableViewCell

@property (nonatomic, weak) id<WXYZ_InviteTopTableViewCellDelegate>delegate;

- (void)showInfo:(WXYZ_ShareModel *)model;

@end

NS_ASSUME_NONNULL_END
