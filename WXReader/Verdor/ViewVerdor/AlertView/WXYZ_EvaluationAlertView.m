//
//  DPEvaluationAlertView.m
//  WXReader
//
//  Created by Andrew on 2018/11/10.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_EvaluationAlertView.h"

@implementation WXYZ_EvaluationAlertView
{
    UIImageView *topImageView;
    UIButton *rejectButton;
}

- (void)createSubviews
{
    [super createSubviews];
    
    [self addSubview:self.alertBackView];
    
    self.showDivider = NO;
    
    self.alertViewTitleLabel.font = kFont30;
    self.alertViewTitleLabel.text = @"应用好评";
    
    self.alertViewDetailContent = @"使用还满意么？满意请点个赞呗";
    
    self.alertViewCancelTitle = @"我要吐槽";
    self.cancelButton.layer.borderColor = kColorRGBA(62, 120, 232, 1).CGColor;
    self.cancelButton.layer.borderWidth = 0.5;
    self.cancelButton.layer.cornerRadius = self.alertViewButtonHeight / 2;
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.cancelButton setTitleColor:kColorRGBA(62, 120, 232, 1) forState:UIControlStateNormal];
    
    self.alertViewConfirmTitle = @"五星好评";
    self.confirmButton.layer.cornerRadius = self.alertViewButtonHeight / 2;
    self.confirmButton.backgroundColor = kColorRGBA(62, 120, 232, 1);
    [self.confirmButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    
    rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rejectButton setTitle:@"残忍拒绝" forState:UIControlStateNormal];
    [rejectButton setTitleColor:kGrayTextLightColor forState:UIControlStateNormal];
    [rejectButton.titleLabel setFont:kMainFont];
    [rejectButton addTarget:self action:@selector(closeAlertView) forControlEvents:UIControlEventTouchUpInside];
    [self.alertBackView addSubview:rejectButton];
    
}

- (void)showAlertView
{
    [super showAlertView];
    
    topImageView = [[UIImageView alloc] init];
    topImageView.image = [UIImage imageNamed:@"public_evaluation.png"];
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.alertBackView addSubview:topImageView];
    
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.alertBackView.mas_width).with.multipliedBy(0.8);
        make.height.mas_equalTo(self.alertBackView.mas_width).with.multipliedBy(0.5);
        make.centerX.mas_equalTo(self.alertBackView.mas_centerX);
        make.bottom.mas_equalTo(self.alertBackView.mas_top).with.offset(2 * kMargin);
    }];
    
    [self.alertViewTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.alertBackView.mas_top).with.offset(3 * kMargin);
    }];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.alertViewContentScrollView.mas_bottom).with.offset(kMargin);
        make.centerX.mas_equalTo(self.alertViewTitleLabel.mas_centerX);
        make.width.mas_equalTo(self.alertBackView.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(self.alertViewButtonHeight);
    }];
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.confirmButton.mas_centerX);
        make.top.mas_equalTo(self.confirmButton.mas_bottom).with.offset(kHalfMargin);
        make.width.mas_equalTo(self.confirmButton.mas_width);
        make.height.mas_equalTo(self.confirmButton.mas_height);
    }];
    
    [rejectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.confirmButton.mas_centerX);
        make.top.mas_equalTo(self.cancelButton.mas_bottom).with.offset(5);
        make.width.mas_equalTo(self.confirmButton.mas_width);
        make.height.mas_equalTo(self.confirmButton.mas_height);
    }];
    
    [self.alertBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.alertViewWidth);
        make.bottom.mas_equalTo(rejectButton.mas_bottom).with.offset(kHalfMargin);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
}

@end
