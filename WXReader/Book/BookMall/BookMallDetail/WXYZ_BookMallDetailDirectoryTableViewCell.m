//
//  WXYZ_BookMallDetailDirectoryTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/8/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookMallDetailDirectoryTableViewCell.h"
#import "WXYZ_TagView.h"

@implementation WXYZ_BookMallDetailDirectoryTableViewCell
{
    UILabel *timeLabel;
    UIButton *catalogueButton;
    UILabel *catalogueDetailLabel;
    WXYZ_TagView *tagView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    // 目录列
    catalogueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    catalogueButton.backgroundColor = [UIColor clearColor];
    catalogueButton.hidden = YES;
    [catalogueButton addTarget:self action:@selector(catalogueClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:catalogueButton];
    
    [catalogueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(kLabelHeight + kHalfMargin);
    }];
    
    UIImageView *catalogueIcon = [[UIImageView alloc] init];
    catalogueIcon.image = [UIImage imageNamed:@"book_directory"];
    catalogueIcon.userInteractionEnabled = YES;
    [catalogueButton addSubview:catalogueIcon];
    
    [catalogueIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.centerY.mas_equalTo(catalogueButton.mas_centerY);
        make.height.mas_equalTo(kMargin);
        make.width.mas_equalTo(kMargin);
    }];
    
    UILabel *catalogueTitle = [[UILabel alloc] init];
    catalogueTitle.text = @"目录";
    catalogueTitle.font = kMainFont;
    catalogueTitle.textColor = kBlackColor;
    catalogueTitle.textAlignment = NSTextAlignmentLeft;
    [catalogueButton addSubview:catalogueTitle];
    
    [catalogueTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(catalogueIcon.mas_right).with.offset(5);
        make.centerY.mas_equalTo(catalogueIcon.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(catalogueIcon.mas_height);
    }];
    
    // 横线
    for (int i = 0; i < 2; i ++) {
        UIView *cellLine = [[UIView alloc] init];
        cellLine.hidden = NO;
        cellLine.backgroundColor = kGrayLineColor;
        [catalogueButton addSubview:cellLine];
        
        [cellLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kMargin);
            if (i == 0) {
                make.top.mas_equalTo(kCellLineHeight);
            } else {
                make.bottom.mas_equalTo(catalogueButton.mas_bottom).with.offset(- kCellLineHeight);
            }
            make.width.mas_equalTo(self.mas_width).with.offset( - kMargin);
            make.height.mas_equalTo(kCellLineHeight);
        }];
    }
    
    UIImageView *connerImageView = [[UIImageView alloc] init];
    connerImageView.image = [[UIImage imageNamed:@"public_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    connerImageView.userInteractionEnabled = YES;
    connerImageView.tintColor = kGrayTextColor;
    [catalogueButton addSubview:connerImageView];
    
    [connerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(catalogueButton.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(catalogueButton.mas_centerY);
        make.width.height.mas_equalTo(10);
    }];
    
    timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = kFont10;
    timeLabel.textColor = kGrayTextColor;
    [catalogueButton addSubview:timeLabel];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(connerImageView.mas_left).with.offset(- kQuarterMargin);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(catalogueButton.mas_height);
    }];
    
    catalogueDetailLabel = [[UILabel alloc] init];
    catalogueDetailLabel.backgroundColor = [UIColor clearColor];
    catalogueDetailLabel.textAlignment = NSTextAlignmentLeft;
    catalogueDetailLabel.font = kFont12;
    catalogueDetailLabel.textColor = kGrayTextColor;
    [catalogueButton addSubview:catalogueDetailLabel];
    
    [catalogueDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(catalogueTitle.mas_right);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(timeLabel.mas_left).with.offset(- kQuarterMargin);
        make.height.mas_equalTo(catalogueButton.mas_height);
    }];
    
    // 标签
    tagView = [[WXYZ_TagView alloc] init];
    tagView.tagAlignment = WXYZ_TagAlignmentLeft;
    tagView.tagBorderStyle = WXYZ_TagBorderStyleFill;
    [self.contentView addSubview:tagView];
    
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(catalogueButton.mas_bottom).with.offset(kHalfMargin);
        make.width.mas_equalTo(self.contentView.mas_width).with.offset(- 2 * kHalfMargin);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
}

- (void)catalogueClick
{
    if (self.catalogueButtonClickBlock) {
        self.catalogueButtonClickBlock();
    }
}

- (void)setBookModel:(WXYZ_ProductionModel *)bookModel
{
    if (bookModel && (_bookModel != bookModel)) {
        _bookModel = bookModel;
        
        tagView.tagArray = bookModel.tag;
        
        timeLabel.text = bookModel.last_chapter_time?:@"";
        [timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:timeLabel]);
        }];
        
        catalogueDetailLabel.text = bookModel.last_chapter?:@"";
        
        catalogueButton.hidden = NO;
        
    }
}

@end
