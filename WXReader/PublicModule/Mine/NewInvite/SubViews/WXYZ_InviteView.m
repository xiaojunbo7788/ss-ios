//
//  WXYZ_InviteView.m
//  WXReader
//
//  Created by geng on 2020/10/3.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_InviteView.h"
#import "UILabel+WXCreate.h"
@interface WXYZ_InviteView ()

@property (nonatomic, strong) UIImageView *view1;
@property (nonatomic, strong) UIImageView *view2;
@property (nonatomic, strong) UIImageView *view3;
@property (nonatomic, strong) UIImageView *view4;
@property (nonatomic, strong) UIImageView *view5;
@property (nonatomic, strong) UIImageView *view6;
@property (nonatomic, strong) UILabel *centerLabel;

@end

@implementation WXYZ_InviteView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_squre"]];
        [self addSubview:self.view1];
        
        self.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_squre"]];
        [self addSubview:self.view2];
        
        self.view3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_squre"]];
        [self addSubview:self.view3];
        
        self.view4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_squre"]];
        [self addSubview:self.view4];
        
        self.view5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_squre"]];
        [self addSubview:self.view5];
        
        self.view6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_squre"]];
        [self addSubview:self.view6];
        
        self.centerLabel = [UILabel creatByColor:[UIColor whiteColor] withFont:[UIFont systemFontOfSize:21]];
        self.centerLabel.text = @"邀请记录";
        [self addSubview:self.centerLabel];
        
        
        [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(5);
        }];
        
        [self.view2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view1.mas_right).offset(8);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(8);
        }];
        
        [self.view3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view2.mas_right).offset(8);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(10);
        }];
        
        [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view3.mas_right).offset(10);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(20);
            make.height.mas_greaterThanOrEqualTo(10);
        }];
        
        [self.view4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.centerLabel.mas_right).offset(10);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(10);
        }];
        
        [self.view5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view4.mas_right).offset(8);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(8);
        }];
        
        [self.view6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view5.mas_right).offset(8);
            make.right.mas_equalTo(self.mas_right).priorityLow();
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(5);
        }];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
