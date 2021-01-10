//
//  WXYZ_PayTableViewCell.m
//  WXReader
//
//  Created by geng on 2020/10/3.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_PayTableViewCell.h"
#import "UILabel+WXCreate.h"
@interface WXYZ_PayTableViewCell ()

@property (nonatomic, strong) UIImageView *payImage;
@property (nonatomic, strong) UILabel *payName;
@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation WXYZ_PayTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.payImage = [[UIImageView alloc] initWithImage:HoldImage];
        [self.contentView addSubview:self.payImage];
        
        self.payName = [UILabel creatByColor:[UIColor blackColor] withFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:self.payName];
        
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightBtn setImage:[UIImage imageNamed:@"pay_channel_failure"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.rightBtn];
        
        [self.payImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(35);
        }];
        [self.payName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.payImage.mas_right).offset(12);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(50);
            make.height.mas_greaterThanOrEqualTo(20);
        }];
        [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
             make.right.mas_equalTo(-12);
             make.width.height.mas_equalTo(12);
             make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }
    return self;
}

//- (void)showInfo:(WXYZ_PayModel *)model {
//    [self.payImage  setImageWithURL:[NSURL URLWithString:model.icon ?: @""] placeholder:HoldImage];
//    self.payName.text = model.title;
//    if (model.choose) {
//        [self.rightBtn setImage:[UIImage imageNamed:@"pay_channel_success"] forState:UIControlStateNormal];
//    } else {
//        [self.rightBtn setImage:[UIImage imageNamed:@"pay_channel_failure"] forState:UIControlStateNormal];
//    }
//    
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
