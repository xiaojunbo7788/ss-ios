//
//  WXYZ_InviteBottomTableViewCell.m
//  WXReader
//
//  Created by geng on 2020/10/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_InviteBottomTableViewCell.h"
#import "UILabel+WXCreate.h"
@interface WXYZ_InviteBottomTableViewCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *nameView;
@property (nonatomic, strong) UILabel *timeView;
@property (nonatomic, strong) UILabel *rightView;
@property (nonatomic, strong) UILabel *errView;

@end

@implementation WXYZ_InviteBottomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.bgView = [[UIView alloc] init];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.bgView];
        
        
        self.leftImageView = [[UIImageView alloc] init];
        self.leftImageView.layer.masksToBounds = true;
        self.leftImageView.layer.cornerRadius = 21;
        self.leftImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.leftImageView];
        
        self.nameView = [UILabel creatByColor:[UIColor blackColor] withFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:self.nameView];
        
        self.timeView = [UILabel creatByColor:WX_COLOR_WITH_HEX(0x656565) withFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:self.timeView];
        
        self.rightView = [UILabel creatByColor:WX_COLOR_WITH_HEX(0xE53323) withFont:[UIFont systemFontOfSize:14]];
        self.rightView.text = @"邀请成功";
        [self.contentView addSubview:self.rightView];
        
        self.errView = [UILabel creatByColor:WX_COLOR_WITH_HEX(0x656565) withFont:[UIFont systemFontOfSize:15]];
        self.errView.text = @"暂无邀请记录";
        self.errView.hidden = true;
        self.errView.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.errView];
        
        [self makeConstrants];
        
    }
    return self;
}

- (void)makeConstrants {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.width.height.mas_equalTo(42);
    }];
    
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(5);
        make.top.mas_equalTo(self.leftImageView.mas_top).offset(2);
        make.width.mas_greaterThanOrEqualTo(20);
        make.height.mas_greaterThanOrEqualTo(10);
    }];
    
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(5);
        make.top.mas_equalTo(self.nameView.mas_bottom).offset(5);
        make.width.mas_greaterThanOrEqualTo(20);
        make.height.mas_greaterThanOrEqualTo(10);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(20);
        make.height.mas_greaterThanOrEqualTo(10);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-17);
        
    }];
    
    [self.errView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(self.bgView);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(20);
    }];
}

- (void)showData:(NSDictionary *)info {
    NSString *code = @"";
    NSString *nickname = info[@"nickname"];
    NSString *created_at = info[@"created_at"];
    NSString *userHead = @"";
    if ([info.allKeys containsObject:@"code"]) {
        code = info[@"code"];
    }
    if ([info.allKeys containsObject:@"userHead"]) {
        userHead = info[@"userHead"];
    }
    
    if ([code isEqualToString:@"-1"]) {
        self.nameView.hidden = true;
        self.leftImageView.hidden = true;
        self.rightView.hidden = true;
        self.errView.hidden = false;
    } else {
        [_leftImageView setImageWithURL:[NSURL URLWithString:userHead] placeholder:HoldUserAvatar];
        _nameView.text = nickname;
        _timeView.text = created_at;
    }
  
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
