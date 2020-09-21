//
//  WXYZ_AudioSoundRecommendedTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/7/8.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundRecommendedTableViewCell.h"
#import "WXYZ_ProductionCollectionManager.h"

#import "WXYZ_AudioSoundRecommendedModel.h"

@implementation WXYZ_AudioSoundRecommendedTableViewCell
{
    UILabel *readTimeLabel;
    UIButton *collectionButton;
}

- (void)createSubviews
{
    [super createSubviews];
    
    self.tagView.hidden = YES;
    
    self.authorLabel.textColor = kMainColor;
    
    UIImageView *readTimeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_directory_readtime"]];
    [self.contentView addSubview:readTimeIcon];
    
    [readTimeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.authorLabel.mas_right).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(self.authorLabel.mas_centerY);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(10);
    }];
    
    readTimeLabel = [[UILabel alloc] init];
    readTimeLabel.font = kFont12;
    readTimeLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:readTimeLabel];
    
    [readTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(readTimeIcon.mas_right).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(readTimeIcon.mas_centerY);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(CGFLOAT_MIN);
    }];
    
    collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    collectionButton.layer.cornerRadius = 10;
    collectionButton.layer.borderColor = kMainColor.CGColor;
    collectionButton.layer.borderWidth = 0.4;
    [collectionButton addTarget:self action:@selector(collectionClick) forControlEvents:UIControlEventTouchUpInside];
    [collectionButton setTitle:@"收藏" forState:UIControlStateNormal];
    [collectionButton setTitleColor:kMainColor forState:UIControlStateNormal];
    [collectionButton.titleLabel setFont:kFont11];
    [self.contentView addSubview:collectionButton];
    
    [collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(readTimeIcon.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(20);
    }];
    
}

- (void)setListModel:(WXYZ_AudioSoundPlayPageModel *)listModel
{
    [super setListModel:listModel];
    
    self.authorLabel.text = listModel.finished?:@"";
    [self.authorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.authorLabel]);
    }];
    
    readTimeLabel.text = [NSString stringWithFormat:@"%zd", listModel.total_views];
    [readTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:readTimeLabel]);
    }];
    
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCollectedWithProduction_id:self.listModel.production_id]) {
        [collectionButton setTitle:@"已收藏" forState:UIControlStateNormal];
    } else {
        [collectionButton setTitle:@"收藏" forState:UIControlStateNormal];
    }
}

- (void)collectionClick
{
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCollectedWithProduction_id:self.listModel.production_id]) {
//        !self.clickBlock ?: self.clickBlock(self.listModel.production_id);
        return;
    }
    
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] addCollectionWithProductionModel:self.listModel]) {
        [collectionButton setTitle:@"已收藏" forState:UIControlStateNormal];
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已收藏"];
    } else {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"收藏失败"];
    }
    
    [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.listModel.production_id productionType:WXYZ_ProductionTypeAudio complete:nil];
}

@end
