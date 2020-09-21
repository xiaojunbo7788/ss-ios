//
//  WXYZ_RankListTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/6/14.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RankListTableViewCell.h"

@implementation WXYZ_RankListTableViewCell
{
    WXYZ_ProductionCoverView *iconTop;
    WXYZ_ProductionCoverView *iconCenter;
    WXYZ_ProductionCoverView *iconBottom;
    
    UILabel *rankTitleLabel;
    UILabel *rankDescriptionLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    iconBottom = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    [self.contentView addSubview:iconBottom];
    
    iconCenter = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    [self.contentView addSubview:iconCenter];
    
    iconTop = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    [self.contentView addSubview:iconTop];
    
    [iconTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(kGeometricHeight(60, 3, 4));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
    [iconCenter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(iconTop.mas_bottom);
        make.right.mas_equalTo(iconTop.mas_right).with.offset(kMargin);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(kGeometricHeight(50, 3, 4));
    }];
    
    [iconBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(iconCenter.mas_bottom);
        make.right.mas_equalTo(iconCenter.mas_right).with.offset(kMargin);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(kGeometricHeight(40, 3, 4));
    }];
    
    rankTitleLabel = [[UILabel alloc] init];
    rankTitleLabel.textColor = kBlackColor;
    rankTitleLabel.backgroundColor = kGrayViewColor;
    rankTitleLabel.font = kMainFont;
    [self.contentView addSubview:rankTitleLabel];
    
    [rankTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(iconTop.mas_centerY).with.offset(- 2);
        make.left.mas_equalTo(iconBottom.mas_right).with.offset(kMargin);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(30);
    }];
    
    rankDescriptionLabel = [[UILabel alloc] init];
    rankDescriptionLabel.textColor = kGrayTextColor;
    rankDescriptionLabel.backgroundColor = kGrayViewColor;
    rankDescriptionLabel.font = kFont12;
    [self.contentView addSubview:rankDescriptionLabel];
    
    [rankDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iconTop.mas_centerY).with.offset(2);
        make.left.mas_equalTo(rankTitleLabel.mas_left);
        make.width.mas_equalTo(rankTitleLabel.mas_width);
        make.height.mas_equalTo(rankTitleLabel.mas_height);
    }];
}

- (void)setRankListModel:(WXYZ_RankListModel *)rankListModel
{
    _rankListModel = rankListModel;
    for (int i = 0; i < rankListModel.icon.count; i++) {
        switch (i) {
            case 0:
                iconTop.coverImageURL = [rankListModel.icon objectOrNilAtIndex:0];
                break;
            case 1:
                iconCenter.coverImageURL = [rankListModel.icon objectOrNilAtIndex:1];
                if ([rankListModel.icon objectAtIndex:1].length <= 0) {
                    iconCenter.hidden = YES;
                }
                break;
            case 2:
                iconBottom.coverImageURL = [rankListModel.icon objectOrNilAtIndex:2];
                if ([rankListModel.icon objectAtIndex:2].length <= 0) {
                    iconBottom.hidden = YES;
                }
                break;

            default:
                break;
        }
    }

    rankTitleLabel.backgroundColor = [UIColor whiteColor];
    rankTitleLabel.text = rankListModel.list_name?:@"";
    
    rankDescriptionLabel.backgroundColor = [UIColor whiteColor];
    rankDescriptionLabel.text = rankListModel.rankDescription?:@"";
}

- (void)setProductionType:(WXYZ_ProductionType)productionType
{
    [super setProductionType:productionType];
    
    iconTop.productionType = productionType;
}

@end
