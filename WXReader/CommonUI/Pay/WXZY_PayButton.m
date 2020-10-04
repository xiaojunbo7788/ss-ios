//
//  WXZY_PayButton.m
//  WXReader
//
//  Created by geng on 2020/10/3.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXZY_PayButton.h"

@interface WXZY_PayButton ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;

@end

@implementation WXZY_PayButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_y_star"]];
        [self addSubview:self.imageView];
        
        self.label = [UILabel creatByColor:[UIColor whiteColor] withFont:[UIFont systemFontOfSize:15]];
        self.label.text = @"获取VIP无限看";
        [self addSubview:self.label];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(13);
        }];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.imageView.mas_right).offset(7);
             make.centerY.mas_equalTo(self.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(50);
            make.height.mas_greaterThanOrEqualTo(20);
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
