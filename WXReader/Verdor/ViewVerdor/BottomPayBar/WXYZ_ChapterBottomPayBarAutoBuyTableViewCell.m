//
//  WXYZ_ChapterBottomPayBarAutoBuyTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ChapterBottomPayBarAutoBuyTableViewCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import "KLSwitch.h"

@implementation WXYZ_ChapterBottomPayBarAutoBuyTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    WS(weakSelf)
    KLSwitch *autoBuySwitch = [[KLSwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 51 - kMargin, 10, 51, 31) didChangeHandler:^(BOOL isOn) {
        [weakSelf autoBuyNetRequest];
    }];
    autoBuySwitch.transform = CGAffineTransformMakeScale(0.7, 0.7);//缩放
    autoBuySwitch.onTintColor = kMainColor;
    [autoBuySwitch setDefaultOnState:[WXYZ_UserInfoManager shareInstance].auto_sub];
    [self.contentView addSubview:autoBuySwitch];
    
    [autoBuySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.width.mas_equalTo(51);
        make.height.mas_offset(31);
    }];
    
    
    UILabel *autoBuyTitleLabel = [[UILabel alloc] init];
    autoBuyTitleLabel.text = @"自动购买下一章";
    autoBuyTitleLabel.textColor = kBlackColor;
    autoBuyTitleLabel.font = kMainFont;
    autoBuyTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:autoBuyTitleLabel];
    
    [autoBuyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.right.mas_equalTo(autoBuySwitch.mas_left).with.offset(- kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
}

- (void)autoBuyNetRequest
{
    [WXYZ_NetworkRequestManger POST:Auto_Sub_Chapter parameters:nil model:nil success:^(BOOL isSuccess, NSDictionary * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            NSString *auto_sub_state = [NSString stringWithFormat:@"%@", [[t_model objectForKey:@"data"] objectForKey:@"auto_sub"]];
            if (auto_sub_state && auto_sub_state.length > 0) {
                AudioServicesPlaySystemSound(1519);
                [WXYZ_UserInfoManager shareInstance].auto_sub = [auto_sub_state isEqualToString:@"1"];
            }
        }
    } failure:nil];
}

@end
