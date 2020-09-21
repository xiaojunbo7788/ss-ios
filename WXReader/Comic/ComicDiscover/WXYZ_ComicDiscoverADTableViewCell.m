//
//  WXYZ_ComicDiscoverADTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/10/11.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDiscoverADTableViewCell.h"
#import "WXYZ_ADManager.h"

@interface WXYZ_ComicDiscoverADTableViewCell ()

@property (nonatomic, strong) WXYZ_ADModel *adModel;

@property (nonatomic, weak) WXYZ_ADManager *adView;

@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation WXYZ_ComicDiscoverADTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    WXYZ_ADManager *adView = [[WXYZ_ADManager alloc] initWithFrame:CGRectMake(kHalfMargin, kHalfMargin, SCREEN_WIDTH - kMargin, (SCREEN_WIDTH - 2 * kHalfMargin) / 2) adType:WXYZ_ADViewTypeNone adPosition:WXYZ_ADViewPositionNone];
    self.adView = adView;
    __weak typeof(adView) weakView = adView;
    WS(weakSelf)
    adView.closeBlock = ^{
        [weakView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1.0);
            make.top.equalTo(self.contentView);
        }];
        [weakSelf.mainTableView reloadData];
    };
    adView.userInteractionEnabled = YES;
    adView.layer.cornerRadius = 8.0f;
    [self.contentView addSubview:adView];
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, 7, 4));
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.textColor = kBlackColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = kMainFont;
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(adView.mas_bottom).with.offset(kHalfMargin);
        make.height.mas_equalTo(kMargin);
        make.right.mas_equalTo(self.contentView.mas_right);
    }];
    
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:splitLine];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).priorityLow();
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(0.1);
    }];
}

- (void)setAdModel:(WXYZ_ADModel * _Nonnull)adModel refresh:(BOOL)refresh {
    if (refresh || (adModel.advert_id != _adModel.advert_id)) {
        adModel.ad_width = CGRectGetWidth(self.contentView.bounds);
        adModel.ad_height = CGRectGetHeight(self.contentView.bounds);
        _adModel = adModel;
        self.adView.adModel = adModel;
        if (adModel.ad_type == 1) {
            [self.adView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo((SCREEN_WIDTH - 2 * kHalfMargin) / 2.0);
            }];
        } else {
            [self.adView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo((SCREEN_WIDTH - 2 * kHalfMargin) * 1.0 / 3.0);
            }];
        }
        
        self.titleLabel.text = adModel.ad_title ?: @"";
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            if (self.titleLabel.text.length == 0 || adModel.ad_type == 2) {
                make.height.mas_equalTo(CGFLOAT_MIN);
            } else {
                make.height.mas_equalTo(kMargin);
            }
        }];
    }
}

@end
