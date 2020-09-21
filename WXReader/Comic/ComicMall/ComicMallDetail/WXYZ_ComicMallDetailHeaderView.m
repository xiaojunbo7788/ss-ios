//
//  WXYZ_ComicMallDetailHeaderView.m
//  WXReader
//
//  Created by Andrew on 2019/5/29.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMallDetailHeaderView.h"
#import "WXYZ_TagView.h"
#import "WXYZ_ProductionCollectionManager.h"
#import "UIView+AZGradient.h"
#import "UIImage+Blur.h"
#import "WXYZ_DetailHeadContentView.h"
@interface WXYZ_ComicMallDetailHeaderView () <WXYZ_DetailHeadContentViewDelegate>

@property (nonatomic, weak) UIImageView *backHoldImageView;
@property (nonatomic, strong) WXYZ_DetailHeadContentView *headContentView;

@end

@implementation WXYZ_ComicMallDetailHeaderView {
    UIView *backFrostedGlassView;
    
    UIView *tagBottomView;
    
    UIImageView *comicCoverImageView;
    
    UILabel *comicTitleLabel;
    
    UILabel *authorLabel;
    
    WXYZ_TagView *tagView;
    
    UIVisualEffectView *effectView;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    UIImageView *backHoldImageView = [[UIImageView alloc] init];
    self.backHoldImageView = backHoldImageView;
    backHoldImageView.image = HoldImage;
    backHoldImageView.contentMode = UIViewContentModeScaleAspectFill;
    backHoldImageView.clipsToBounds = YES;
    [self addSubview:backHoldImageView];
    
    [backHoldImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(Comic_Detail_HeaderView_Height);
    }];
    
    backFrostedGlassView = [[UIView alloc] init];
    [self addSubview:backFrostedGlassView];
    
    [backFrostedGlassView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(backHoldImageView);
    }];
    
    effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.alpha = 0;
    [self addSubview:effectView];
    
    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(backHoldImageView);
    }];
    
    tagBottomView = [[UIView alloc] init];
    tagBottomView.backgroundColor = kWhiteColor;
    tagBottomView.layer.cornerRadius = 20;
    [self addSubview:tagBottomView];
    
    [tagBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(kMargin);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(80 + kMargin);
    }];
    
    comicCoverImageView = [[UIImageView alloc] initWithCornerRadiusAdvance:8 rectCornerType:UIRectCornerAllCorners];
    comicCoverImageView.image = HoldImage;
    comicCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [comicCoverImageView zy_attachBorderWidth:2 color:kWhiteColor];
    [self addSubview:comicCoverImageView];
    
    [comicCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kMargin);
        make.bottom.mas_equalTo(self.mas_bottom).with.offset(- kQuarterMargin);
        make.width.mas_equalTo((255) / 2);
        make.height.mas_equalTo(kGeometricHeight((255) / 2, 3, 4));
    }];
    
    
    self.headContentView = [[WXYZ_DetailHeadContentView alloc] initWithFrame:CGRectZero];
    self.headContentView.delegate = self;
    [self addSubview:self.headContentView];
    
    [self.headContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(tagBottomView.mas_top);
        make.left.mas_equalTo(comicCoverImageView.mas_right).with.offset(kHalfMargin);
        make.right.mas_equalTo(self.mas_right);
        make.height.mas_greaterThanOrEqualTo(100);
        
    }];
    
    
    tagView = [[WXYZ_TagView alloc] init];
    
    tagView.tagAlignment = WXYZ_TagAlignmentLeft;
    tagView.tagBorderStyle = WXYZ_TagBorderStyleFill;
    tagView.tagSpacing = 15;
    tagView.tagViewCornerRadius = 8.5;
    [self addSubview:tagView];
    
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(comicCoverImageView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(tagBottomView.mas_top).with.offset(kHalfMargin);
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(20);
    }];
}

- (void)setComicProductionModel:(WXYZ_ProductionModel *)comicProductionModel {
    
    if (_comicProductionModel != comicProductionModel) {
        _comicProductionModel = comicProductionModel;
        WS(weakSelf)
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:comicProductionModel.horizontal_cover.length > 0 ?comicProductionModel.horizontal_cover:comicProductionModel.vertical_cover]  options:YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SS(strongSelf)
                weakSelf.backHoldImageView.image = [image imgWithLightAlpha:0.4 radius:3 colorSaturationFactor:1.8];
                strongSelf->backFrostedGlassView.backgroundColor = kColorRGBA(0, 0, 0, 0.4);
            });
        }];
        [comicCoverImageView setImageWithURL:[NSURL URLWithString:comicProductionModel.vertical_cover] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
        [self.headContentView showInfo:comicProductionModel withType:1];
        tagView.tagArray = comicProductionModel.tag;
    }
}

- (NSAttributedString *)formatAttributedText:(NSString *)normalText {
    NSMutableAttributedString *authorAttString = [[NSMutableAttributedString alloc] initWithString:normalText?:@""];
    return authorAttString;
}

- (void)setHeaderViewAlpha:(CGFloat)headerViewAlpha {
    _headerViewAlpha = headerViewAlpha;
    
    [tagBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(80 * headerViewAlpha);
    }];
    
    self.headContentView.alpha = headerViewAlpha;
    comicCoverImageView.alpha = headerViewAlpha;
    comicTitleLabel.alpha = headerViewAlpha;
    authorLabel.alpha = headerViewAlpha;
    tagView.alpha = headerViewAlpha;
    backFrostedGlassView.alpha = headerViewAlpha;
    effectView.alpha = 1 - headerViewAlpha;
}

- (void)reloadHeaderView
{
    if (![[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] isCollectedWithProductionModel:self.comicProductionModel]) {
        self.headContentView.collectButton.backgroundColor = kMainColor;
        [self.headContentView.collectButton setTitle:@"＋收藏" forState:UIControlStateNormal];
    } else {
        self.headContentView.collectButton.backgroundColor = [kMainColor colorWithAlphaComponent:0.75];
        [self.headContentView.collectButton setTitle:@"已收藏" forState:UIControlStateNormal];
    }
}

#pragma mark - WXYZ_DetailHeadContentViewDelegate
- (void)onClickCollectionBtn {
    if (![[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] isCollectedWithProductionModel:self.comicProductionModel]) {
            
        [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.comicProductionModel.production_id productionType:WXYZ_ProductionTypeComic complete:nil];
        
        if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] addCollectionWithProductionModel:self.comicProductionModel]) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已收藏"];
        }
    
        [self reloadHeaderView];
    }
}


@end
