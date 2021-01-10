//
//  WXYZ_InviteTopTableViewCell.m
//  WXReader
//
//  Created by geng on 2020/10/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_InviteTopTableViewCell.h"
#import "WXYZ_InviteTopBgView.h"
#import "WXYZ_InviteView.h"
@interface WXYZ_InviteTopTableViewCell ()

@property (nonatomic, strong) WXYZ_InviteTopBgView *topBgView;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) WXYZ_InviteView *inviteView;
@end

@implementation WXYZ_InviteTopTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.topBgView = [[WXYZ_InviteTopBgView alloc] init];
        WS(weakSelf)
        self.topBgView.onClick = ^{
            [weakSelf.delegate onBindUser];
        };
        self.topBgView.layer.masksToBounds = true;
        self.topBgView.backgroundColor = [UIColor whiteColor];
        self.topBgView.layer.cornerRadius = 4;
        [self.contentView addSubview:self.topBgView];
        
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareButton.layer.masksToBounds = true;
        self.shareButton.layer.cornerRadius = 4;
        [self.shareButton setImage:[UIImage imageNamed:@"invite_btn"] forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.shareButton];
        
        self.inviteView = [[WXYZ_InviteView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.inviteView];
        
        
        [self makeConstrants];
    }
    return self;
}

- (void)makeConstrants {
    [self.topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.height.mas_equalTo(209);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topBgView.mas_bottom).offset(18);
        make.left.mas_equalTo(13);
        make.right.mas_equalTo(-13);
        make.height.mas_equalTo(58);
    }];
    
    [self.inviteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.shareButton.mas_bottom).offset(20);
        make.height.mas_equalTo(20);
        make.width.mas_greaterThanOrEqualTo(80);
    }];
}

- (void)showInfo:(WXYZ_ShareModel *)model {
    [self.topBgView showInfo:model];
}

- (void)buttonPress {
    [self.delegate onShare];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
