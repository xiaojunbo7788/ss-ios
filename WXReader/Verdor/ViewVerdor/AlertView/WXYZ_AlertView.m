//
//  DPBasicAlertView.m
//  WXReader
//
//  Created by Andrew on 2018/11/8.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_AlertView.h"

@interface WXYZ_AlertView () <UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer *dismissTapGesture;
    
    CGFloat _alertViewWidth;
    CGFloat _alertViewButtonWidth;
    CGFloat _alertViewButtonHeight;
    
    NSString *_alertViewTitle;
    
    BOOL _inController;
}

@end

@implementation WXYZ_AlertView


- (instancetype)init
{
    if (self = [super init]) {
        
        _inController = NO;
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (instancetype)initInController
{
    if (self = [super init]) {
        
        _inController = YES;
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (void)initialize
{
    _showDivider = YES;
    _alertViewButtonHeight = 50.0f;
    _alertViewWidth = SCREEN_WIDTH - 3 * kMargin;
    self.alertButtonType = WXYZ_AlertButtonTypeDouble;
    self.alertViewDisappearType = WXYZ_AlertViewDisappearTypeNormal;
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = kBlackTransparentColor;
    if (_inController) {
        [kMainWindow.rootViewController.view addSubview:self];
    } else {
        [kMainWindow addSubview:self];
    }
    if (!self.superview) {
        UIViewController *vc = [UIApplication sharedApplication].windows.firstObject.rootViewController;
        [vc.view addSubview:self];
    }
    
    dismissTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAlertView)];
    dismissTapGesture.numberOfTapsRequired = 1;
    dismissTapGesture.delegate = self;
    [self addGestureRecognizer:dismissTapGesture];
}

- (void)createSubviews
{
    // 添加背景
    [self addSubview:self.alertBackView];
    
    // 添加关闭按钮
    [self.alertBackView addSubview:self.closeButton];
    
    // 添加标题
    [self.alertBackView addSubview:self.alertViewTitleLabel];
    
    // 添加内容
    [self.alertBackView addSubview:self.alertViewContentScrollView];
    
    [self.alertViewContentScrollView addSubview:self.alertViewContentLabel];
    
    // 取消按钮
    [self.alertBackView addSubview:self.cancelButton];
    
    // 确认按钮
    [self.alertBackView addSubview:self.confirmButton];
}

// 显示弹框
- (void)showAlertView
{
    [self.alertBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_alertViewWidth);
        make.bottom.mas_equalTo(self.confirmButton.mas_bottom).with.offset(0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).with.offset(0);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.alertBackView.mas_top);
        make.right.mas_equalTo(self.alertBackView.mas_right);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.alertViewTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertBackView.mas_left).with.offset(kMargin);
        make.right.mas_equalTo(self.alertBackView.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(self.alertBackView.mas_top).with.offset(kMargin);
        if (self.alertViewTitle.length > 0) {
            make.height.mas_equalTo(30);
        } else {
            make.height.mas_equalTo(CGFLOAT_MIN);
        }
    }];
    
    [self.alertViewContentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.alertViewTitleLabel.centerX);
        make.top.mas_equalTo(self.alertViewTitleLabel.mas_bottom);
        make.width.mas_equalTo(self.alertViewWidth - 2 * kMargin);
        make.height.mas_equalTo([self getContentScrollViewHeight]);
    }];
    
    [self.alertViewContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(self.alertViewContentScrollView.mas_width);
        make.height.mas_equalTo([self getContentLabelHeight]);
    }];
    

    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertBackView.mas_left).with.offset(0);
        make.top.mas_equalTo(self.alertViewContentScrollView.mas_bottom).with.offset(kMargin);
        make.height.mas_equalTo(_alertViewButtonHeight);
        if (self.alertButtonType == WXYZ_AlertButtonTypeSingleConfirm) {
            make.width.mas_equalTo(CGFLOAT_MIN);
        } else {
            make.width.mas_equalTo(_alertViewButtonWidth);
        }
    }];
    
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.alertBackView.mas_right).with.offset(0);
        make.top.mas_equalTo(self.alertViewContentScrollView.mas_bottom).with.offset(kMargin);
        make.height.mas_equalTo(_alertViewButtonHeight);
        if (self.alertButtonType == WXYZ_AlertButtonTypeSingleCancel) {
            make.width.mas_equalTo(CGFLOAT_MIN);
        } else {
            make.width.mas_equalTo(_alertViewButtonWidth);
        }
    }];
    
    if (self.alertButtonType != WXYZ_AlertButtonTypeNone && self.showDivider) {
        {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = kGrayLineColor;
            [self.alertBackView addSubview:line];
            
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.alertBackView.mas_left);
                make.right.mas_equalTo(self.alertBackView.mas_right);
                make.height.mas_equalTo(kCellLineHeight + 0.1f);
                make.bottom.mas_equalTo(self.alertBackView.mas_bottom).with.offset(- _alertViewButtonHeight);
            }];
        }
        
        if (self.alertButtonType == WXYZ_AlertButtonTypeDouble) {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = kGrayLineColor;
            [self.alertBackView addSubview:line];
            
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.confirmButton.mas_left);
                make.top.mas_equalTo(self.confirmButton.mas_top);
                make.height.mas_equalTo(self.confirmButton.mas_height);
                make.width.mas_equalTo(kCellLineHeight + 0.1f);
            }];
        }
    }
}

// 关闭弹框
- (void)closeAlertView {
    [self removeFromSuperview];
}

- (CGFloat)getContentLabelHeight
{
    if (self.alertViewDetailAttributeContent.length > 0) {
        return [WXYZ_ViewHelper getDynamicHeightWithLabelFont:kMainFont labelWidth:SCREEN_WIDTH - 3 * kMargin labelText:self.alertViewDetailAttributeContent.string] + 2 * kMargin;
    } else if (self.alertViewDetailContent.length > 0) {
        return [WXYZ_ViewHelper getDynamicHeightWithLabelFont:kMainFont labelWidth:SCREEN_WIDTH - 3 * kMargin labelText:self.alertViewDetailContent] + kMargin;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)getContentScrollViewHeight
{
    if ([self getContentLabelHeight] > (SCREEN_HEIGHT / 3)) {
        [self.alertViewContentScrollView setContentSize:CGSizeMake(0, [self getContentLabelHeight])];
        return SCREEN_HEIGHT / 3;
    }
    return [self getContentLabelHeight];
}

- (NSString *)alertViewTitle
{
    if (!_alertViewTitle) {
        return @"提示";
    }
    return _alertViewTitle;
}

- (void)setAlertViewTitle:(NSString *)alertViewTitle
{
    _alertViewTitle = alertViewTitle;
    self.alertViewTitleLabel.text = alertViewTitle;
}

- (void)setAlertViewDetailContent:(NSString *)alertViewDetailContent
{
    _alertViewDetailContent = alertViewDetailContent;
    self.alertViewContentLabel.text = alertViewDetailContent;
}

- (void)setAlertViewDetailAttributeContent:(NSMutableAttributedString *)alertViewDetailAttributeContent
{
    _alertViewDetailAttributeContent = alertViewDetailAttributeContent;
    self.alertViewContentLabel.attributedText = alertViewDetailAttributeContent;
}

- (void)setAlertViewCancelTitle:(NSString *)alertViewCancelTitle
{
    [self.cancelButton setTitle:alertViewCancelTitle forState:UIControlStateNormal];
}

- (void)setAlertViewConfirmTitle:(NSString *)alertViewConfirmTitle
{
    [self.confirmButton setTitle:alertViewConfirmTitle forState:UIControlStateNormal];
}

- (void)setAlertButtonType:(WXYZ_AlertButtonType)alertButtonType
{
    _alertButtonType = alertButtonType;
    
    switch (alertButtonType) {
        case WXYZ_AlertButtonTypeNone:
            _alertViewButtonWidth = CGFLOAT_MIN;
            _alertViewButtonHeight = CGFLOAT_MIN;
            break;
        case WXYZ_AlertButtonTypeSingleConfirm:
        case WXYZ_AlertButtonTypeSingleCancel:
            _alertViewButtonWidth = _alertViewWidth;
            _alertViewButtonHeight = 44.0f;
            break;
        case WXYZ_AlertButtonTypeDouble:
            _alertViewButtonWidth = (_alertViewWidth) / 2;
            _alertViewButtonHeight = 44.0f;
            break;
            
        default:
            break;
    }
}

- (void)setAlertViewDisappearType:(WXYZ_AlertViewDisappearType)alertViewDisappearType
{
    _alertViewDisappearType = alertViewDisappearType;
    
    if (alertViewDisappearType != WXYZ_AlertViewDisappearTypeNormal) {
        [self removeGestureRecognizer:dismissTapGesture];
    }
}

#pragma mark - lazy
- (UIView *)alertBackView
{
    if (!_alertBackView) {
        _alertBackView = [[UIView alloc] init];
        _alertBackView.backgroundColor = [UIColor whiteColor];
        _alertBackView.layer.cornerRadius = 8;
        [self addSubview:_alertBackView];
    }
    return _alertBackView;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.tintColor = kGrayTextLightColor;
        [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        [_closeButton setImage:[[UIImage imageNamed:@"public_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAlertView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)alertViewTitleLabel
{
    if (!_alertViewTitleLabel) {
        _alertViewTitleLabel = [[UILabel alloc] init];
        _alertViewTitleLabel.text = self.alertViewTitle;
        _alertViewTitleLabel.backgroundColor = [UIColor clearColor];
        _alertViewTitleLabel.font = kBoldFont16;
        _alertViewTitleLabel.textColor = kBlackColor;
        _alertViewTitleLabel.textAlignment = NSTextAlignmentCenter;
        _alertViewTitleLabel.numberOfLines = 1;
    }
    return _alertViewTitleLabel;
}

- (UIScrollView *)alertViewContentScrollView
{
    if (!_alertViewContentScrollView) {
        _alertViewContentScrollView = [[UIScrollView alloc] init];
        _alertViewContentScrollView.showsVerticalScrollIndicator = NO;
        _alertViewContentScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _alertViewContentScrollView;
}

- (YYLabel *)alertViewContentLabel
{
    if (!_alertViewContentLabel) {
        _alertViewContentLabel = [[YYLabel alloc] init];
        _alertViewContentLabel.numberOfLines = 0;
        _alertViewContentLabel.font = kMainFont;
        _alertViewContentLabel.textColor = kGrayTextLightColor;
        _alertViewContentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _alertViewContentLabel;
}

- (UIButton *)confirmButton
{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = kWhiteColor;
        _confirmButton.layer.cornerRadius = 8;
        [_confirmButton.titleLabel setFont:kMainFont];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:kMainColor forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = kWhiteColor;
        _cancelButton.layer.cornerRadius = 8;
        [_cancelButton.titleLabel setFont:kMainFont];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - action
- (void)cancelButtonClick
{
    if (self.cancelButtonClickBlock) {
        self.cancelButtonClickBlock();
    }
    [self closeAlertView];
}

- (void)confirmButtonClick
{
    if (self.confirmButtonClickBlock) {
        self.confirmButtonClickBlock();
    }
    
    if (self.alertViewDisappearType == WXYZ_AlertViewDisappearTypeNever) {
        return;
    }
    
    [self closeAlertView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isEqual:self.confirmButton] || [touch.view isEqual:self]) {
        return YES;
    } else {
        return NO;
    }
}

@end
