//
//  WXYZ_TopAlertView.m
//  WXReader
//
//  Created by Andrew on 2019/6/7.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_TopAlertView.h"

@interface WXYZ_TopAlertView ()

@property (nonatomic, strong) UIView *alertBottonView;

@property (nonatomic, strong) UILabel *alertTitleLabel;

@property (nonatomic, strong) UIImageView *alertImageView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

//下滑返回手势
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizer;

@end

@implementation WXYZ_TopAlertView

- (instancetype)init
{
    if (self = [super init]) {

        self.userInteractionEnabled = YES;
        self.backgroundColor = kColorRGBA(0, 0, 0, 0.0);
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [kMainWindow addSubview:self];
        
        [self createSubViews];
        
        self.recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizerHandle:)];
        [self.recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self addGestureRecognizer:self.recognizer];
    }
    return self;
}

- (void)createSubViews
{
    self.alertBottonView.frame = CGRectMake(0, - PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT);
    [self addSubview:self.alertBottonView];
    
    [self.alertBottonView addSubview:self.alertImageView];
    [self.alertImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.bottom.mas_equalTo(- kMargin);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.alertBottonView addSubview:self.alertTitleLabel];
    [self.alertTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertImageView.mas_right).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(self.alertImageView.mas_centerY);
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(30);
    }];
    
    self.indicatorView.hidden = YES;
    [self.alertBottonView addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.bottom.mas_equalTo(- kMargin);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
}

//处理手势
- (void)recognizerHandle:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [self hiddenAlertView:0];
    }
}

- (void)showAlertView
{
    [UIView animateWithDuration:kAnimatedDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
        self.alertBottonView.frame = CGRectMake(0, 0, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT);
        if (self.showMask) {
            self.backgroundColor = kBlackTransparentColor;
        }
    } completion:^(BOOL finished) {
        WS(weakSelf)
        self.isShowing = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.alertDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf hiddenAlertView];
        });
    }];
}

- (void)hiddenAlertView
{
    [self hiddenAlertView:1];
}

- (void)hiddenAlertView:(CGFloat)delay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kAnimatedDuration delay:delay usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            self.alertBottonView.frame = CGRectMake(0, - PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT);
            if (self.showMask) {
                self.backgroundColor = kColorRGBA(0, 0, 0, 0.01);
            }
        } completion:^(BOOL finished) {
            [self removeAlertView];
            self.isShowing = NO;
        }];        
    });
}

- (void)removeAlertView
{
    if (self.alertDissmissBlock) {
        self.alertDissmissBlock();
    }
    
    [self removeAllSubviews];
    [self removeFromSuperview];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self && !self.showMask){
        return nil;
    }
    return hitView;
}

- (void)setAlertTitle:(NSString *)alertTitle
{
    _alertTitle = alertTitle;
    
    self.alertTitleLabel.text = [WXYZ_UtilsHelper formatStringWithObject:alertTitle];
}

- (void)setAlertType:(WXYZ_TopAlertType)alertType
{
    if (alertType == WXYZ_TopAlertTypeSuccess) {
        self.alertImageView.image = [UIImage imageNamed:@"tips_success"];
    }
    
    if (alertType == WXYZ_TopAlertTypeError) {
        self.alertImageView.image = [UIImage imageNamed:@"tips_error"];
    }
    
    if (alertType == WXYZ_TopAlertTypeLoading) {
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
        
        self.showMask = YES;
    }
}

- (UIView *)alertBottonView
{
    if (!_alertBottonView) {
        _alertBottonView = [[UIView alloc] init];
        _alertBottonView.backgroundColor = kWhiteColor;
    }
    return _alertBottonView;
}

- (UIImageView *)alertImageView
{
    if (!_alertImageView) {
        _alertImageView = [[UIImageView alloc] init];
    }
    return _alertImageView;
}

- (UILabel *)alertTitleLabel
{
    if (!_alertTitleLabel) {
        _alertTitleLabel = [[UILabel alloc] init];
        _alertTitleLabel.textAlignment = NSTextAlignmentLeft;
        _alertTitleLabel.textColor = kBlackColor;
        _alertTitleLabel.font = kMainFont;
    }
    return _alertTitleLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        _indicatorView.color = kBlackColor;
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

@end
