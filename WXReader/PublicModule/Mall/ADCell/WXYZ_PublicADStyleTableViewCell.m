//
//  WXYZ_PublicADStyleTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_PublicADStyleTableViewCell.h"
#import "WXYZ_WebViewViewController.h"
#import "WXYZ_ADManager.h"

@interface WXYZ_PublicADStyleTableViewCell ()

@property (nonatomic, weak) WXYZ_ADManager *adView;

@property (nonatomic, strong) WXYZ_ADModel *adModel;

@end

@implementation WXYZ_PublicADStyleTableViewCell

- (void)createSubviews {
    [super createSubviews];
    
    WXYZ_ADManager *adView = [[WXYZ_ADManager alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - kMargin, kGeometricHeight(SCREEN_WIDTH - kMargin, 3, 1)) adType:WXYZ_ADViewTypeNone adPosition:WXYZ_ADViewPositionNone];
    __weak typeof(adView) weakView = adView;
    WS(weakSelf)
    adView.closeBlock = ^{
        [weakView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1.0);
        }];
        [weakSelf.mainTableView reloadData];
    };
    self.adView = adView;
    [self.contentView addSubview:adView];
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, 3, 1));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (void)setAdModel:(WXYZ_ADModel *)adModel refresh:(BOOL)refresh {
    if (refresh || (adModel.advert_id != _adModel.advert_id)) {
        _adModel = adModel;
        self.adView.adModel = adModel;
        if (adModel.ad_width > 0 && adModel.ad_height > 0) {
            CGFloat scale = (CGFloat)adModel.ad_height / adModel.ad_width;
            [self.adView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(CGRectGetWidth(self.adView.bounds) * scale);
            }];
        }
    }
}

@end
