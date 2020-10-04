//
//  WXZY_RechargeButton.m
//  WXReader
//
//  Created by geng on 2020/10/3.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXZY_RechargeButton.h"
#import "UILabel+WXCreate.h"
@interface WXZY_RechargeButton ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *button;
@end

@implementation WXZY_RechargeButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.nameLabel = [UILabel creatByColor:WX_COLOR_WITH_HEX(0x838383) withFont:[UIFont systemFontOfSize:13]];
        self.nameLabel.text = @"充值购买松子";
        [self addSubview:self.nameLabel];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = WX_COLOR_WITH_HEX(0x838383);
        [self addSubview:self.lineView];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.height.mas_equalTo(13);
            make.width.mas_greaterThanOrEqualTo(50);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.nameLabel.mas_bottom);
            make.width.mas_equalTo(self.nameLabel.mas_width);
            make.height.mas_equalTo(1);
             make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
               self.button.opaque = true;
               [self addSubview:self.button];
               [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
                   make.left.top.right.bottom.mas_equalTo(self);
               }];
               [self.button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonPress {
    if (self.onClick) {
        self.onClick();
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
