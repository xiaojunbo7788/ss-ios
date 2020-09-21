//
//  DPUpdateAlertView.m
//  WXReader
//
//  Created by Andrew on 2018/11/30.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_UpdateAlertView.h"

@implementation WXYZ_UpdateAlertView
{
    UIImageView *topImageView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    self.closeButton.hidden = YES;
    self.showDivider = NO;
    
    [self addSubview:self.alertBackView];
    
    topImageView = [[UIImageView alloc] init];
    topImageView.image = [UIImage imageNamed:@"alert_update_top.png"];
    [self.alertBackView addSubview:topImageView];
    [self.alertBackView sendSubviewToBack:topImageView];
    
    self.alertViewTitle = @"";
    self.alertViewContentLabel.textAlignment = NSTextAlignmentLeft;
    
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setTitleColor:kColorRGBA(62, 120, 232, 1) forState:UIControlStateNormal];
    self.alertViewCancelTitle = @"再等等";
    
    self.alertViewContentScrollView.showsVerticalScrollIndicator = YES;
    
    self.confirmButton.layer.cornerRadius = self.alertViewButtonHeight / 2;
    self.confirmButton.backgroundColor = kColorRGBA(62, 120, 232, 1);
    [self.confirmButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [self.alertBackView addSubview:self.confirmButton];
    self.alertViewConfirmTitle = @"去更新";
}

- (void)showAlertView
{
    [super showAlertView];
    
    [self.alertBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.confirmButton.mas_bottom).with.offset(kMargin);
        make.centerY.mas_equalTo(self.mas_centerY).with.offset(self.alertViewWidth * 0.12);
    }];
    
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.alertBackView.mas_width);
        make.height.mas_equalTo(self.alertBackView.mas_width).with.multipliedBy(0.4788);
        make.centerX.mas_equalTo(self.alertBackView.mas_centerX);
        make.bottom.mas_equalTo(self.alertBackView.mas_top).with.offset(kMargin);
    }];
    
    CGFloat labelHeight = [WXYZ_ViewHelper getDynamicHeightWithLabelFont:kMainFont labelWidth:SCREEN_WIDTH - 3 * kMargin labelText:self.alertViewDetailContent] + kMargin;
    if (labelHeight < self.alertViewWidth * 0.24) {
        labelHeight = self.alertViewWidth * 0.24;
        [self.alertViewContentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(labelHeight);
        }];
    } else if (labelHeight > SCREEN_HEIGHT / 3) {
        labelHeight = SCREEN_HEIGHT / 3;
    }
    
    [self.alertViewContentScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(labelHeight);
    }];
    
    [self.cancelButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertBackView.mas_left).with.offset(kMargin);
        if (self.alertButtonType == WXYZ_AlertButtonTypeSingleConfirm) {
            make.width.mas_equalTo(CGFLOAT_MIN);
        } else {
            make.width.mas_equalTo(self.alertViewWidth / 2 - kMargin - kHalfMargin);
        }
    }];
    
    [self.confirmButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.alertBackView.mas_right).with.offset(- kMargin);
        if (self.alertButtonType == WXYZ_AlertButtonTypeSingleCancel) {
            make.width.mas_equalTo(CGFLOAT_MIN);
        } else if (self.alertButtonType == WXYZ_AlertButtonTypeSingleConfirm) {
            make.width.mas_equalTo(self.alertViewWidth - 2 * kMargin);
        } else {
            make.width.mas_equalTo(self.alertViewWidth / 2 - kMargin - kHalfMargin);
        }
    }];
}

- (void)setUpdateMessage:(NSString *)updateMessage
{
    _updateMessage = updateMessage;
    self.alertViewDetailContent = updateMessage;
}

@end
