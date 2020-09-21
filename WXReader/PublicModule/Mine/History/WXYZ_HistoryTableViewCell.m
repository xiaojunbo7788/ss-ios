//
//  WXYZ_HistoryTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/1/8.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_HistoryTableViewCell.h"

@interface WXYZ_HistoryTableViewCell ()

@property (nonatomic, strong) UIView *cellADView;

@end

@implementation WXYZ_HistoryTableViewCell
{
    WXYZ_ProductionCoverView *bookImageView;
    UIButton *continueReadButton;
    UILabel *bookTitleLabel;
    UILabel *recordLabel;
    UILabel *timeLabel;
    
    UIView *adView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    // 图片
    bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    bookImageView.userInteractionEnabled = YES;
    bookImageView.hidden = YES;
    [self.contentView addSubview:bookImageView];
    
    [bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(BOOK_WIDTH_SMALL - kMargin);
        make.height.mas_equalTo(kGeometricHeight(BOOK_WIDTH_SMALL - kMargin, 3, 4));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
    continueReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    continueReadButton.hidden = YES;
    continueReadButton.layer.cornerRadius = 12;
    continueReadButton.backgroundColor = kMainColor;
    [continueReadButton setTitle:@"继续阅读" forState:UIControlStateNormal];
    [continueReadButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [continueReadButton.titleLabel setFont:kFont11];
    [continueReadButton addTarget:self action:@selector(continueReadClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:continueReadButton];
    
    [continueReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(bookImageView.mas_centerY);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(24);
    }];
    
    // 书名
    bookTitleLabel = [[UILabel alloc] init];
    bookTitleLabel.numberOfLines = 1;
    bookTitleLabel.hidden = YES;
    bookTitleLabel.backgroundColor = kWhiteColor;
    bookTitleLabel.font = kMainFont;
    bookTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:bookTitleLabel];
    
    [bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookImageView.mas_right).with.offset(kHalfMargin);
        make.right.mas_equalTo(continueReadButton.mas_left).with.offset(- kHalfMargin);
        make.top.mas_equalTo(bookImageView.mas_top);
        make.height.mas_equalTo(bookImageView.mas_height).with.multipliedBy(0.5);
    }];
    
    // 阅读记录
    recordLabel = [[UILabel alloc] init];
    recordLabel.hidden = YES;
    recordLabel.textColor = kGrayTextColor;
    recordLabel.font = kFont11;
    recordLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:recordLabel];
    
    [recordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookTitleLabel.mas_left);
        make.top.mas_equalTo(bookTitleLabel.mas_bottom);
        make.width.mas_equalTo(bookTitleLabel.mas_width);
        make.height.mas_equalTo(20);
    }];
    
    // 更新记录
    timeLabel = [[UILabel alloc] init];
    timeLabel.hidden = YES;
    timeLabel.textColor = kGrayTextColor;
    timeLabel.font = kFont10;
    timeLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:timeLabel];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookTitleLabel.mas_left);
        make.top.mas_equalTo(recordLabel.mas_bottom);
        make.width.mas_equalTo(bookTitleLabel.mas_width);
        make.height.mas_equalTo(recordLabel.mas_height);
    }];
    
    adView = [[UIView alloc] init];
    adView.backgroundColor = [UIColor whiteColor];
    adView.hidden = YES;
    [self.contentView addSubview:adView];
    
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
}

- (void)setCellADView:(UIView *)cellADView
{
    _cellADView = cellADView;
    [adView addSubview:cellADView];
}

- (void)setProductionModel:(WXYZ_ProductionModel *)productionModel
{
    _productionModel = productionModel;
    
    if (productionModel.ad_type != 0) {
        bookImageView.hidden = YES;
        continueReadButton.hidden = YES;
        bookTitleLabel.hidden = YES;
        recordLabel.hidden = YES;
        timeLabel.hidden = YES;
        adView.hidden = NO;
        return;
    }
    
    bookImageView.hidden = NO;
    continueReadButton.hidden = NO;
    bookTitleLabel.hidden = NO;
    recordLabel.hidden = NO;
    timeLabel.hidden = NO;
    adView.hidden = YES;
    
    bookTitleLabel.text = productionModel.name?:@"";
    
    if (productionModel.vertical_cover.length > 0) {
        bookImageView.coverImageURL = productionModel.vertical_cover;
    } else if (productionModel.horizontal_cover.length > 0) {
        bookImageView.coverImageURL = productionModel.horizontal_cover;
    } else {
        bookImageView.coverImageURL = productionModel.cover;
    }
    
    if (self.productionType == WXYZ_ProductionTypeAudio) {
        recordLabel.text = [NSString stringWithFormat:@"上次收听至：%@", productionModel.record_title ?: @""];
    } else {
        recordLabel.text = [NSString stringWithFormat:@"上次阅读至：%@", productionModel.record_title ?: @""];
    }
    
    timeLabel.text = [NSString stringWithFormat:@"%@  更新至第%@章", productionModel.last_chapter_time ?: @"", [WXYZ_UtilsHelper formatStringWithInteger:productionModel.total_chapters] ?: @""];
}

- (void)continueReadClick
{
    if (self.continueReadBlock) {
        self.continueReadBlock(_productionModel.production_id);
    }
}

- (void)setProductionType:(WXYZ_ProductionType)productionType
{
    [super setProductionType:productionType];
    
    bookImageView.productionType = productionType;
    if (productionType == WXYZ_ProductionTypeAudio) {
        [continueReadButton setTitle:@"继续收听" forState:UIControlStateNormal];
    } else {
        [continueReadButton setTitle:@"继续阅读" forState:UIControlStateNormal];
    }
}

@end
