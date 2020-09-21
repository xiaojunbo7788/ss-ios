//
//  WXYZ_MineTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/6/20.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MineTableViewCell.h"

#import "WXYZ_UserCenterModel.h"

@implementation WXYZ_MineTableViewCell
{
    UIImageView *iconImageView;
    UILabel *titleLabel;
    UILabel *subTitleLabel;
    UIImageView *connerImageView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    iconImageView = [[UIImageView alloc] init];
    iconImageView.image = HoldImage;
    [self.contentView addSubview:iconImageView];
    
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin + kQuarterMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(20);
    }];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = kWhiteColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = kBlackColor;
    titleLabel.font = kMainFont;
    [self.contentView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconImageView.mas_right).with.offset(kHalfMargin + kQuarterMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(kLabelHeight);
    }];
    
    connerImageView = [[UIImageView alloc] init];
    connerImageView.image = [UIImage imageNamed:@"public_more"];
    [self.contentView addSubview:connerImageView];
    
    [connerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(10);
    }];
    
    subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.textAlignment = NSTextAlignmentRight;
    subTitleLabel.textColor = kBlackColor;
    subTitleLabel.backgroundColor = kWhiteColor;
    subTitleLabel.font = kFont12;
    [self.contentView addSubview:subTitleLabel];
    
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(connerImageView.mas_left).with.offset(- 5);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(kLabelHeight);
    }];
}

- (void)setCellModel:(WXYZ_UserCenterListModel *)cellModel
{
    if (_cellModel != cellModel) {
        _cellModel = cellModel;
        
        titleLabel.text = cellModel.title?:@"";
        subTitleLabel.text = cellModel.desc?:@"";
        titleLabel.textColor = [UIColor colorWithHexString:cellModel.title_color?:@""];
        subTitleLabel.textColor = [UIColor colorWithHexString:cellModel.desc_color?:@""];
        [iconImageView setImageWithURL:[NSURL URLWithString:cellModel.icon?:@""] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
        
        if (cellModel.enable) {
            connerImageView.hidden = NO;
        } else {
            connerImageView.hidden = YES;
        }
    }
}

@end
