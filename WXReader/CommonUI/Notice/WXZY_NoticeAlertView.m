//
//  WXZY_NoticeAlertView.m
//  WXReader
//
//  Created by geng on 2020/10/10.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXZY_NoticeAlertView.h"

@interface WXZY_NoticeAlertView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIButton *bottomBtn;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation WXZY_NoticeAlertView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.masksToBounds = true;
        self.contentView.layer.cornerRadius = 8;
        [self addSubview:self.contentView];

        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.backgroundColor = WX_COLOR_WITH_HEX(0xF1C33F);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.titleLabel.text = @"系统公告";
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];

        self.msgLabel = [[UILabel alloc]init];
        self.msgLabel.font = [UIFont systemFontOfSize:13];
        self.msgLabel.numberOfLines = 0;
        self.msgLabel.textColor = [UIColor blackColor];
        self.msgLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.msgLabel];
        
        self.lineView = [[UIView alloc]init];
        self.lineView.backgroundColor = WX_COLOR_WITH_HEX(0xF5F5F5);
        [self.contentView addSubview:self.lineView];
        
        self.bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomBtn setTitle:@"知道了" forState:UIControlStateNormal];
        [self.bottomBtn setTitleColor:WX_COLOR_WITH_HEX(0xFF7666) forState:UIControlStateNormal];
        [self.bottomBtn addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.bottomBtn];
        
        [self makeConstrants];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    }
    return self;
}


- (void)buttonPress {
    [self hide];
}

- (void)makeConstrants {
    @weakify(self);
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.mas_equalTo(self.mas_centerY).offset(-20);
        make.left.mas_equalTo(self.mas_left).offset(33);
        make.right.mas_equalTo(self.mas_right).offset(-33);
        make.height.mas_greaterThanOrEqualTo(100);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.mas_equalTo(self.contentView.mas_top).offset(0);
        make.left.mas_equalTo(self.contentView.mas_left).offset(0);
        make.right.mas_equalTo(self.contentView.mas_right).offset(0);
        make.height.mas_greaterThanOrEqualTo(53);
    }];

    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.mas_equalTo(self.contentView.mas_left).offset(14);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-14);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(17);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-24-55).priorityLow();
    }];
    
       
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).offset(25);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
       

    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.height.mas_equalTo(47);
    }];

}

- (void)setMsg:(NSString *)msg {
    _msg = msg;
    self.msgLabel.text = msg;
}

- (void)showInView:(UIView *)view {
    self.alpha = 1;
    self.isShow = true;
    self.contentView.alpha = 0;
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.top.right.bottom.equalTo(view);
    }];
    @weakify(self);
    [UIView animateWithDuration:0.15 animations:^{
        @strongify(self);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.contentView.alpha = 1;
    }];

}

- (void)hide {

    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self);
        self.contentView.alpha = 0;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    } completion:^(BOOL finished) {
        @strongify(self);
         self.isShow = false;
         [self removeFromSuperview];
    }];

}



@end
