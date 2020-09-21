//
//  WXYZ_CountDownView.m
//  WXReader
//
//  Created by Andrew on 2019/4/9.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_CountDownView.h"
#import "WXYZ_GCDTimer.h"

@interface WXYZ_CountDownView ()

@property (nonatomic, strong) UILabel *countDownLabel;

@property (nonatomic, strong) UILabel *endActiveLabel;

@property (nonatomic, strong) UILabel *hoursLabel;

@property (nonatomic, strong) UILabel *minutesLabel;

@property (nonatomic, strong) UILabel *secondsLabel;

@property (nonatomic, strong) UILabel *hoursPointLabel;

@property (nonatomic, strong) UILabel *minutesPointLabel;

@property (nonatomic, strong) WXYZ_GCDTimer *timer;

@end

@implementation WXYZ_CountDownView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    self.countDownLabel.hidden = NO;
    [self addSubview:self.countDownLabel];
    
    self.endActiveLabel.hidden = YES;
    [self addSubview:self.endActiveLabel];
    
    [self.countDownLabel addSubview:self.hoursLabel];
    [self.countDownLabel addSubview:self.minutesLabel];
    [self.countDownLabel addSubview:self.secondsLabel];
    [self.countDownLabel addSubview:self.hoursPointLabel];
    [self.countDownLabel addSubview:self.minutesPointLabel];
    
    [self.hoursLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    [self.minutesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.hoursLabel.mas_right).with.offset(5);
        make.top.mas_equalTo(self.hoursLabel.mas_top);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(self.hoursLabel.mas_height);
    }];
    
    [self.secondsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.minutesLabel.mas_right).with.offset(5);
        make.top.mas_equalTo(self.hoursLabel.mas_top);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(self.hoursLabel.mas_height);
    }];
    
    [self.hoursPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.hoursLabel.mas_right);
        make.top.mas_equalTo(self.hoursLabel.mas_top);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(self.hoursLabel.mas_height);
    }];
    
    [self.minutesPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.minutesLabel.mas_right);
        make.top.mas_equalTo(self.minutesLabel.mas_top);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(self.minutesLabel.mas_height);
    }];
}

- (void)setTimeStamp:(NSInteger)timeStamp
{
    _timeStamp = timeStamp;
    
    if (_timeStamp != 0) {
        [self.timer stopTimer];
        [self.timer startTimerWithTimeDuration:timeStamp];
    } else {
        self.countDownLabel.hidden = YES;
        self.endActiveLabel.hidden = NO;
    }
}

- (void)getDetailTimeWithTimeStamp:(NSInteger)timeStamp
{
    NSInteger ms = timeStamp;
    NSInteger ss = 1;
    NSInteger mi = ss * 60;
    NSInteger hh = mi * 60;
    
    // 剩余的
    NSInteger hour = (ms) / hh;// 时
    NSInteger minute = (ms - hour * hh) / mi;// 分
    NSInteger second = (ms - hour * hh - minute * mi) / ss;// 秒
    
    self.hoursLabel.text = [self formatTimeStringWithTimeStamp:hour];
    self.minutesLabel.text = [self formatTimeStringWithTimeStamp:minute];
    self.secondsLabel.text = [self formatTimeStringWithTimeStamp:second];
    self.hoursPointLabel.hidden = NO;
    self.minutesPointLabel.hidden = NO;
    
    [self.hoursLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.hoursLabel]);
    }];
    
    [self.minutesLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.minutesLabel]);
    }];
    
    [self.secondsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.secondsLabel]);
    }];
}

- (NSString *)formatTimeStringWithTimeStamp:(NSInteger)timeStamp
{
    return [[NSString stringWithFormat:@"%zd", timeStamp] intValue] < 10?[NSString stringWithFormat:@"0%zd", timeStamp]:[NSString stringWithFormat:@"%zd", timeStamp];
}

- (UILabel *)countDownLabel
{
    if (!_countDownLabel) {
        _countDownLabel = [self basicLabel];
    }
    return _countDownLabel;
}

- (UILabel *)endActiveLabel
{
    if (!_endActiveLabel) {
        _endActiveLabel = [self basicCountDownLabel];
        _endActiveLabel.font = kFont12;
        _endActiveLabel.text = @"活动已结束";
    }
    return _endActiveLabel;
}

- (WXYZ_GCDTimer *)timer
{
    if (!_timer) {
        WS(weakSelf)
        _timer = [[WXYZ_GCDTimer alloc] initCountdownTimerWithTimeDuration:10 immediatelyCallBack:YES];
        _timer.timerRunningBlock = ^(NSUInteger runTimes, CGFloat currentTime) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.endActiveLabel.hidden = YES;
                weakSelf.countDownLabel.hidden = NO;
                [weakSelf getDetailTimeWithTimeStamp:currentTime];
            });
        };
        _timer.timerFinishedBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.countDownLabel.hidden = YES;
                weakSelf.endActiveLabel.hidden = NO;
            });
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_EndOfTimeLimit object:nil];
        };
    }
    return _timer;
}

- (UILabel *)hoursLabel
{
    if (!_hoursLabel) {
        _hoursLabel = [self basicCountDownLabel];
    }
    return _hoursLabel;
}

- (UILabel *)minutesLabel
{
    if (!_minutesLabel) {
        _minutesLabel = [self basicCountDownLabel];
    }
    return _minutesLabel;
}

- (UILabel *)secondsLabel
{
    if (!_secondsLabel) {
        _secondsLabel = [self basicCountDownLabel];
    }
    return _secondsLabel;
}

- (UILabel *)hoursPointLabel
{
    if (!_hoursPointLabel) {
        _hoursPointLabel = [self basicLabel];
        _hoursPointLabel.hidden = YES;
        _hoursPointLabel.text = @":";
        _hoursPointLabel.textColor = kBlackColor;
        _hoursPointLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _hoursPointLabel;
}

- (UILabel *)minutesPointLabel
{
    if (!_minutesPointLabel) {
        _minutesPointLabel = [self basicLabel];
        _minutesPointLabel.hidden = YES;
        _minutesPointLabel.text = @":";
        _minutesPointLabel.textColor = kBlackColor;
        _minutesPointLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minutesPointLabel;
}

- (UILabel *)basicLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 1;
    label.font = kFont12;
    return label;
}

- (UILabel *)basicCountDownLabel
{
    UILabel *label = [self basicLabel];
    label.layer.cornerRadius = 4;
    label.backgroundColor = kRedColor;
    label.textColor = kWhiteColor;
    label.clipsToBounds = YES;
    return label;
}

@end
