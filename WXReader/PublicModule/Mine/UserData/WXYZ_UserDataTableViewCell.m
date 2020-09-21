//
//  WXYZ_UserDataTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/5/30.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_UserDataTableViewCell.h"

#import "WXYZ_UserDataModel.h"

@implementation WXYZ_UserDataTableViewCell
{
    UILabel *cellTitleLabel;
    UILabel *cellDetailTitleLabel;
    UIImageView *connerImageView;
    UIImageView *avatarImageView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    cellTitleLabel = [[UILabel alloc] init];
    cellTitleLabel.textColor = kBlackColor;
    cellTitleLabel.font = kMainFont;
    cellTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:cellTitleLabel];
    
    [cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(self.contentView.mas_height);
    }];
    
    connerImageView = [[UIImageView alloc] init];
    connerImageView.image = [UIImage imageNamed:@"public_more"];
    [self.contentView addSubview:connerImageView];
    
    [connerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(10);
    }];
    
    avatarImageView = [[UIImageView alloc] init];
    avatarImageView.layer.cornerRadius = 25;
    avatarImageView.clipsToBounds = YES;
    [self.contentView addSubview:avatarImageView];
    
    [avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(connerImageView.mas_left).with.offset(- kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    
    cellDetailTitleLabel = [[UILabel alloc] init];
    cellDetailTitleLabel.font = kFont12;
    cellDetailTitleLabel.textAlignment = NSTextAlignmentRight;
    cellDetailTitleLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:cellDetailTitleLabel];
    
    [cellDetailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cellTitleLabel.mas_right);
        make.right.mas_equalTo(connerImageView.mas_left).with.offset(- kHalfMargin);
        make.top.mas_equalTo(avatarImageView.mas_bottom);
        make.height.mas_equalTo(CGFLOAT_MIN);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin);
    }];
}

- (void)setCellModel:(WXYZ_UserDataListModel *)cellModel
{
    _cellModel = cellModel;
    
    if ([cellModel.action isEqualToString:@"avatar"]) {
        [avatarImageView setImageWithURL:[NSURL URLWithString:cellModel.desc?:@""] placeholder:HoldUserAvatar options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
        [avatarImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(50);
        }];
        cellDetailTitleLabel.text = @"";
        [cellDetailTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CGFLOAT_MIN);
        }];
    } else {
        avatarImageView.image = nil;
        [avatarImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CGFLOAT_MIN);
        }];
        cellDetailTitleLabel.text = cellModel.desc?:@"";
        [cellDetailTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
        }];
    }
    
    cellTitleLabel.text = cellModel.title?:@"";
    cellTitleLabel.textColor = [UIColor colorWithHexString:cellModel.title_color?:@""];
    cellDetailTitleLabel.textColor = [UIColor colorWithHexString:cellModel.desc_color?:@""];
    
    if (cellModel.is_click) {
        connerImageView.hidden = NO;
        [connerImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(10);
        }];
    } else {
        connerImageView.hidden = YES;
        [connerImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(CGFLOAT_MIN);
        }];
    }
}

@end
