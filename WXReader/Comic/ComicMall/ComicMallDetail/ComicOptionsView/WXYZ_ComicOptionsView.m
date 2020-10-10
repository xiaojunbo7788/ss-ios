//
//  WXYZ_ComicOptionsView.m
//  WXReader
//
//  Created by geng on 2020/10/10.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ComicOptionsView.h"

@interface WXYZ_ComicOptionsView ()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation WXYZ_ComicOptionsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.contentView = [[UIView alloc] init];
        [self addSubview:self.contentView];
        
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftButton setTitle:@"普通线路" forState:UIControlStateNormal];
        self.leftButton.layer.masksToBounds = true;
        self.leftButton.layer.cornerRadius = 24/2;
        self.leftButton.layer.borderColor = WX_COLOR_WITH_HEX(0xFF7C3B).CGColor;
        self.leftButton.layer.borderWidth = 1;
        [self.leftButton setTitleColor:WX_COLOR_WITH_HEX(0xFF7C3B) forState:UIControlStateNormal];
        self.leftButton.titleLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:self.leftButton];
        
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightButton setTitle:@"标清" forState:UIControlStateNormal];
        self.rightButton.layer.masksToBounds = true;
        self.rightButton.layer.cornerRadius = 24/2;
        self.rightButton.layer.borderColor = WX_COLOR_WITH_HEX(0xFF7C3B).CGColor;
        self.rightButton.layer.borderWidth = 1;
        [self.rightButton setTitleColor:WX_COLOR_WITH_HEX(0xFF7C3B) forState:UIControlStateNormal];
        self.rightButton.titleLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:self.rightButton];
        
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerY.mas_equalTo(self);
            make.centerX.mas_equalTo(self);
            make.width.mas_greaterThanOrEqualTo(100);
            make.height.mas_equalTo(self.mas_height);
        }];
        
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo(72);
            make.height.mas_equalTo(24);
        }];
        
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.leftButton.mas_right).offset(25);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo(72);
            make.height.mas_equalTo(24);
            make.right.mas_equalTo(self.contentView.mas_right).priorityLow();
        }];
        
        [self.leftButton addTarget:self action:@selector(leftPress) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton addTarget:self action:@selector(rightPress) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return self;
}

- (void)refreshStateView {
    if ([WXYZ_UserInfoManager shareInstance].isVip) {
        if ([WXYZ_UserInfoManager shareInstance].lineData == 1) {
             [self.leftButton setTitle:@"VIP线路" forState:UIControlStateNormal];
        } else {
             [self.leftButton setTitle:@"普通线路" forState:UIControlStateNormal];
        }
        
        if ([WXYZ_UserInfoManager shareInstance].clearData == 1) {
            [self.rightButton setTitle:@"超清" forState:UIControlStateNormal];
        } else {
            [self.rightButton setTitle:@"标清" forState:UIControlStateNormal];
        }
        
    } else {
        [self.leftButton setTitle:@"普通线路" forState:UIControlStateNormal];
        [self.rightButton setTitle:@"标清" forState:UIControlStateNormal];
    }
}

- (void)leftPress {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(changeLineData)]) {
         [self.delegate changeLineData];
    }
    
}

- (void)rightPress {
    if (self.delegate != nil &&  [self.delegate respondsToSelector:@selector(changeClearData)]) {
        [self.delegate changeClearData];
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
