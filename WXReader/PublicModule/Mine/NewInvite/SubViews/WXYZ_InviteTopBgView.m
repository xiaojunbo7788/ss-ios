//
//  WXYZ_InviteTopBgView.m
//  WXReader
//
//  Created by geng on 2020/10/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_InviteTopBgView.h"
#import "UILabel+WXCreate.h"

@interface WXYZ_InviteTopBgView ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *leftNameLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UIImageView *qrImageView;
@property (nonatomic, strong) UILabel *nameLabel1;
@property (nonatomic, strong) UILabel *nameLabel2;
@property (nonatomic, strong) UILabel *nameLabel3;
@property (nonatomic, strong) UILabel *nameLabel4;
@property (nonatomic, strong) UILabel *nameLabel5;

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) BOOL isBind;
@end

@implementation WXYZ_InviteTopBgView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.topView = [[UIView alloc] init];
        self.topView.layer.masksToBounds = true;
        self.topView.layer.cornerRadius = 34/2;
        self.topView.layer.borderColor = [WX_COLOR_WITH_HEX(0xD2D2D2) CGColor];
        self.topView.layer.borderWidth = 0.5;
        [self addSubview:self.topView];
        
        self.leftNameLabel = [UILabel creatByColor:WX_COLOR_WITH_HEX(0x212121) withFont:[UIFont systemFontOfSize:15]];
        self.leftNameLabel.text = @"我的邀请人";
        [self.topView addSubview:self.leftNameLabel];
        
        self.rightLabel = [UILabel creatByColor:WX_COLOR_WITH_HEX(0x656565) withFont:[UIFont systemFontOfSize:15]];
        self.rightLabel.textAlignment = NSTextAlignmentRight;
        [self.topView addSubview:self.rightLabel];
        
        self.rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_win_right"]];
        [self.topView addSubview:self.rightImageView];
        
        self.qrImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ionc_eq"]];
        [self addSubview:self.qrImageView];
        
        self.nameLabel1 = [UILabel creatByColor:[UIColor blackColor] withFont:[UIFont boldSystemFontOfSize:14]];
        self.nameLabel1.text = @"已邀请";
        [self addSubview:self.nameLabel1];
        
        self.nameLabel2 = [UILabel creatByColor:WX_COLOR_WITH_HEX(0xE53323) withFont:[UIFont boldSystemFontOfSize:29]];
        self.nameLabel2.text = @"0";
        [self addSubview:self.nameLabel2];
        
        self.nameLabel3 = [UILabel creatByColor:WX_COLOR_WITH_HEX(0xE53323) withFont:[UIFont systemFontOfSize:12]];
        self.nameLabel3.text = @"人";
        [self addSubview:self.nameLabel3];
        
        self.nameLabel4 = [UILabel creatByColor:[UIColor blackColor] withFont:[UIFont boldSystemFontOfSize:14]];
        self.nameLabel4.text = @"我的邀请码";
        [self addSubview:self.nameLabel4];
        
        self.nameLabel5 = [UILabel creatByColor:WX_COLOR_WITH_HEX(0xE53323) withFont:[UIFont boldSystemFontOfSize:29]];
        self.nameLabel5.text = @"";
        [self addSubview:self.nameLabel5];
        
        self.leftView = [[UIView alloc] initWithFrame:CGRectZero];
        self.leftView.backgroundColor = WX_COLOR_WITH_HEX(0x4846CE);
        [self addSubview:self.leftView];
        
        self.rightView = [[UIView alloc] initWithFrame:CGRectZero];
        self.rightView.backgroundColor = WX_COLOR_WITH_HEX(0x4846CE);
        [self addSubview:self.rightView];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.opaque = true;
        [self.topView addSubview:self.button];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.mas_equalTo(self.topView);
        }];
        [self.button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self makeConstrants];
    }
    return self;
}

- (void)buttonPress {
    if (self.isBind) {
        return;
    }
    if (self.onClick) {
        self.onClick();
    }
}

- (void)makeConstrants {
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25);
        make.right.mas_equalTo(-25);
        make.top.mas_equalTo(14);
        make.height.mas_equalTo(34);
    }];
    
    [self.leftNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(19);
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.width.mas_equalTo(90);
        make.height.mas_greaterThanOrEqualTo(15);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rightImageView.mas_left).offset(-4);
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.left.mas_equalTo(self.leftNameLabel.mas_right);
        make.height.mas_equalTo(20);
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.qrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(22);
        make.left.mas_equalTo(18);
        make.width.height.mas_equalTo(124);
    }];
    
    [self.nameLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.qrImageView.mas_right).offset(22);
        make.top.mas_equalTo(self.qrImageView.mas_top);
        make.width.mas_greaterThanOrEqualTo(50);
        make.height.mas_greaterThanOrEqualTo(15);
    }];
    
    [self.nameLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.qrImageView.mas_right).offset(22);
        make.top.mas_equalTo(self.nameLabel1.mas_bottom).offset(8);
        make.width.mas_greaterThanOrEqualTo(10);
        make.height.mas_greaterThanOrEqualTo(15);
    }];
    
    [self.nameLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel2.mas_right).offset(5);
        make.bottom.mas_equalTo(self.nameLabel2.mas_bottom).offset(-6);
        make.width.mas_greaterThanOrEqualTo(10);
        make.height.mas_greaterThanOrEqualTo(10);
    }];
    
    [self.nameLabel4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.qrImageView.mas_right).offset(22);
        make.top.mas_equalTo(self.nameLabel3.mas_bottom).offset(12);
        make.width.mas_greaterThanOrEqualTo(50);
        make.height.mas_greaterThanOrEqualTo(15);
    }];
    
    [self.nameLabel5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.qrImageView.mas_right).offset(22);
        make.top.mas_equalTo(self.nameLabel4.mas_bottom).offset(8);
        make.width.mas_greaterThanOrEqualTo(50);
        make.height.mas_greaterThanOrEqualTo(15);
    }];
}

- (void)showInfo:(WXYZ_ShareModel *)model {
    if (model.bind_user != nil && model.bind_user.length > 0) {
        self.rightLabel.text = model.bind_user;
        self.isBind = true;
    } else {
        self.rightLabel.text = @"请填写";
        self.isBind = false;
    }
    
    if (model.inviteInfo!=nil && model.inviteInfo[@"count"] != nil) {
        self.nameLabel2.text = model.inviteInfo[@"count"];
    }
    self.nameLabel5.text = model.invite_code;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.leftView.frame = CGRectMake(-10, 48, 20, 20);
    self.rightView.frame = CGRectMake(self.width-10, 48, 20, 20);
    
     [self setCornerOnLeft:CGSizeMake(10, 10) withView:self.rightView];
    [self setCornerOnRight:CGSizeMake(10, 10) withView:self.leftView];
    
}


- (void)setCornerOnRight:(CGSize)size withView:(UIView *)view {
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                     byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                           cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

- (void)setCornerOnLeft:(CGSize)size withView:(UIView *)view  {
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                     byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                           cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
