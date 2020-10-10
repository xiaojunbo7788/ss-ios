
#import "WXZY_CommonPayAlertView.h"
#import "WXZY_PayButton.h"
#import "WXZY_RechargeButton.h"
@interface WXZY_CommonPayAlertView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) WXZY_PayButton *vipButton;
@property (nonatomic, strong) WXZY_RechargeButton *rechargeButton;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *commitButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *centerLineView;


@end

@implementation WXZY_CommonPayAlertView

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
        self.titleLabel.text = @"偷偷告诉你...";
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

        self.vipButton = [[WXZY_PayButton alloc] initWithFrame:CGRectZero];
        self.vipButton.backgroundColor = WX_COLOR_WITH_HEX(0xFF7565);
        self.vipButton.layer.masksToBounds = true;
        self.vipButton.layer.cornerRadius = 18;
        [self.contentView addSubview:self.vipButton];

        self.rechargeButton = [[WXZY_RechargeButton alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.rechargeButton];

        
        
        self.bottomView = [[UIView alloc]init];
        [self.contentView addSubview:self.bottomView];
               
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setTitle:@"狠心拒绝" forState:UIControlStateNormal];
        self.cancelButton.backgroundColor = [UIColor clearColor];
        [self.cancelButton setTitleColor:WX_COLOR_WITH_HEX(0x838383) forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.bottomView addSubview:self.cancelButton];
               
        self.commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.commitButton setTitle:@"立即分享" forState:UIControlStateNormal];
        self.commitButton.backgroundColor = [UIColor clearColor];
        [self.commitButton setTitleColor:WX_COLOR_WITH_HEX(0xFF7565) forState:UIControlStateNormal];
        self.commitButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.bottomView addSubview:self.commitButton];
               
        self.lineView = [[UIView alloc]init];
        self.lineView.backgroundColor = WX_COLOR_WITH_HEX(0xF5F5F5);
        [self.bottomView addSubview:self.lineView];
               
        self.centerLineView = [[UIView alloc]init];
        self.centerLineView.backgroundColor = WX_COLOR_WITH_HEX(0xF5F5F5);
        [self.bottomView addSubview:self.centerLineView];
               
    
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        [self makeConstrants];
        
        [self addActions];
    }
    return self;
}

- (void)addActions {
    @weakify(self)
    self.vipButton.onClick = ^{
        @strongify(self);
        [self hide];
        if (self.onClick) {
            self.onClick(2);
        }
    };
    
    self.rechargeButton.onClick = ^{
        @strongify(self);
          [self hide];
        if (self.onClick) {
            self.onClick(3);
        }
    };
    
    [self.commitButton addTarget:self action:@selector(buttonPress1) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(buttonPress2) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)buttonPress1 {
     [self hide];
    if (self.onClick) {
        self.onClick(1);
    }
}

- (void)buttonPress2 {
    [self hide];
}

- (void)makeConstrants {
    @weakify(self);
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.mas_equalTo(self.mas_centerY).offset(-20);
        make.left.mas_equalTo(self.mas_left).offset(33);
        make.right.mas_equalTo(self.mas_right).offset(-33);
        make.height.mas_greaterThanOrEqualTo(180);
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
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-170).priorityLow();
    }];
    
    [self.vipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(164);
        make.height.mas_equalTo(36);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).offset(25);
    }];
    
    [self.rechargeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(164);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.vipButton.mas_bottom).offset(17);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.mas_equalTo(self.rechargeButton.mas_bottom).offset(19);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(48);
    }];
       
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.top.equalTo(self.bottomView);
        make.height.mas_equalTo(1);
    }];
       
    [self.centerLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.top.mas_equalTo(12);
        make.bottom.mas_equalTo(self.bottomView.mas_bottom).offset(-12);
        make.width.mas_equalTo(1);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.top.bottom.equalTo(self.bottomView);
        make.width.mas_equalTo(self.commitButton.mas_width);
    }];
       
    [self.commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.mas_equalTo(self.cancelButton.mas_right);
        make.top.right.bottom.equalTo(self.bottomView);
    }];

}

- (void)setIsShowRecharge:(BOOL)isShowRecharge {
    _isShowRecharge = isShowRecharge;
    self.rechargeButton.hidden = true;
    [self.rechargeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(164);
        make.height.mas_equalTo(0);
        make.top.mas_equalTo(self.vipButton.mas_bottom).offset(0);
    }];
    
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(14);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-14);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(17);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-130).priorityLow();
    }];
    [self layoutIfNeeded];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
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


- (void)setCornerOnTop:(CGSize)size {
//    if (self.titleLabel.bounds.size.width > 10) {
//        UIBezierPath *maskPath;
//        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.titleLabel.bounds
//                                         byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
//                                               cornerRadii:size];
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        maskLayer.frame = self.titleLabel.bounds;
//        maskLayer.path = maskPath.CGPath;
//        self.titleLabel.layer.mask = maskLayer;
//    }
    
}

- (void)dealloc {

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
