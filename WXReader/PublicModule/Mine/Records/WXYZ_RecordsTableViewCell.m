//
//  WXYZ_RecordsTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/7/12.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RecordsTableViewCell.h"

@implementation WXYZ_RecordsTableViewCell
{
    UILabel *titleLabel;
    UILabel *dateLabel;
    UILabel *moneyLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = kBlackColor;
    titleLabel.font = kMainFont;
    [self.contentView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.bottom.mas_equalTo(self.contentView.mas_centerY).with.offset(- 1);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(SCREEN_WIDTH * 2 / 3);
    }];
    
    dateLabel = [[UILabel alloc] init];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.textColor = kGrayTextLightColor;
    dateLabel.font = kFont12;
    [self.contentView addSubview:dateLabel];
    
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(self.contentView.mas_centerY).with.offset(1);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(SCREEN_WIDTH * 2 / 3);
    }];
    
    moneyLabel = [[UILabel alloc] init];
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.textColor = kBlackColor;
    moneyLabel.font = kFont13;
    [self.contentView addSubview:moneyLabel];
    
    [moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(150);
    }];
}

- (void)setListModel:(WXBookRecordsListModel *)listModel
{
    titleLabel.text = listModel.article;
    dateLabel.text = listModel.date;
    
    if (listModel.detail.length > 0) {
        moneyLabel.text = listModel.detail?:@"";        
    }
}

@end
