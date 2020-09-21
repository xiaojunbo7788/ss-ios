//
//  WXYZ_TagHeadView.m
//  WXReader
//
//  Created by geng on 2020/9/15.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_TagHeadView.h"

@interface WXYZ_TagHeadView ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *lineView1;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *sortButton1;
@property (nonatomic, strong) UIButton *sortButton2;
@property (nonatomic, strong) UIButton *sortButton3;
@property (nonatomic, strong) UIView *lineView2;

@end

@implementation WXYZ_TagHeadView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.topView = [[UIView alloc] init];
        [self addSubview:self.topView];
        
        self.titleView = [[UILabel alloc] init];
        self.titleView.layer.masksToBounds = true;
        self.titleView.layer.cornerRadius = 23/2;
        self.titleView.textColor = kMainColor;
        self.titleView.layer.borderColor = kMainColor.CGColor;
        self.titleView.layer.borderWidth = 0.5;
        self.titleView.font = [UIFont systemFontOfSize:12];
        [self.topView addSubview:self.titleView];
        
        self.lineView1 = [[UIView alloc] init];
        self.lineView1.backgroundColor = kColorXRGB(0xEEEEEE);
        [self addSubview:_lineView1];
        
        self.bottomView = [[UIView alloc] init];
        [self addSubview:self.bottomView];
        
        self.sortButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sortButton1.layer.masksToBounds = true;
        self.sortButton1.layer.cornerRadius = 23/2;
        self.sortButton1.layer.borderColor = kMainColor.CGColor;
        self.sortButton1.layer.borderWidth = 0.5;
        [self.sortButton1 setTitle:@"  上升  " forState:UIControlStateNormal];
        [self.sortButton1 setTitleColor:kMainColor forState:UIControlStateNormal];
        self.sortButton1.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.sortButton1];
        
        self.sortButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sortButton2.layer.masksToBounds = true;
        self.sortButton2.layer.cornerRadius = 23/2;
        self.sortButton2.layer.borderWidth = 0.5;
        self.sortButton2.layer.borderColor = [UIColor clearColor].CGColor;
        [self.sortButton2 setTitle:@"  热门  " forState:UIControlStateNormal];
        [self.sortButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.sortButton2.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.sortButton2];
        
        self.sortButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sortButton3.layer.masksToBounds = true;
        self.sortButton3.layer.cornerRadius = 23/2;
        self.sortButton3.layer.borderWidth = 0.5;
        self.sortButton3.layer.borderColor = [UIColor clearColor].CGColor;
        [self.sortButton3 setTitle:@"  更新  " forState:UIControlStateNormal];
        [self.sortButton3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.sortButton3.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.sortButton3];
        
        self.lineView2 = [[UIView alloc] init];
        self.lineView2.backgroundColor = kColorXRGB(0xEEEEEE);
        [self addSubview:_lineView2];
        
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(self);
            make.height.mas_equalTo(44);
        }];
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.width.mas_greaterThanOrEqualTo(10);
            make.centerY.mas_equalTo(self.titleView.mas_centerY);
            make.height.mas_equalTo(23);
        }];
        
        [self.lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.topView.mas_bottom);
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lineView1.mas_bottom);
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(44);
        }];
        [self.sortButton1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.width.mas_greaterThanOrEqualTo(10);
            make.centerY.mas_equalTo(self.bottomView.mas_centerY);
            make.height.mas_equalTo(23);
        }];
        
        [self.sortButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.sortButton1.mas_right).offset(20);
            make.width.mas_greaterThanOrEqualTo(10);
            make.centerY.mas_equalTo(self.bottomView.mas_centerY);
            make.height.mas_equalTo(23);
        }];
        
        [self.sortButton3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.sortButton2.mas_right).offset(20);
            make.width.mas_greaterThanOrEqualTo(10);
            make.centerY.mas_equalTo(self.bottomView.mas_centerY);
            make.height.mas_equalTo(23);
        }];
        
        [self.lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomView.mas_bottom);
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.sortButton1 addTarget:self action:@selector(button1) forControlEvents:UIControlEventTouchUpInside];
        [self.sortButton2 addTarget:self action:@selector(button2) forControlEvents:UIControlEventTouchUpInside];
        [self.sortButton3 addTarget:self action:@selector(button3) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return self;
}

- (void)button1 {
    [self.delegate selectSort:@""];
    self.sortButton1.layer.borderColor = kMainColor.CGColor;
    [self.sortButton1 setTitleColor:kMainColor forState:UIControlStateNormal];
    self.sortButton2.layer.borderColor = [UIColor clearColor].CGColor;
    [self.sortButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sortButton3.layer.borderColor = [UIColor clearColor].CGColor;
    [self.sortButton3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
}

- (void)button2 {
    [self.delegate selectSort:@"hot"];
    self.sortButton2.layer.borderColor = kMainColor.CGColor;
    [self.sortButton2 setTitleColor:kMainColor forState:UIControlStateNormal];
    self.sortButton1.layer.borderColor = [UIColor clearColor].CGColor;
    [self.sortButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sortButton3.layer.borderColor = [UIColor clearColor].CGColor;
    [self.sortButton3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)button3 {
     [self.delegate selectSort:@"new"];
    self.sortButton3.layer.borderColor = kMainColor.CGColor;
    [self.sortButton3 setTitleColor:kMainColor forState:UIControlStateNormal];
    self.sortButton2.layer.borderColor = [UIColor clearColor].CGColor;
    [self.sortButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sortButton1.layer.borderColor = [UIColor clearColor].CGColor;
    [self.sortButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
