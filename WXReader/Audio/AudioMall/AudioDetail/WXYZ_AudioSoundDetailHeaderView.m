//
//  WXYZ_AudioSoundDetailHeaderView.m
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_MemberViewController.h"

#import "WXYZ_AudioSoundDetailHeaderView.h"

#import "WXYZ_TagView.h"

#import "WXYZ_ProductionCollectionManager.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ADManager.h"

#import "UIView+AZGradient.h"
#import "UILabel+LineBreak.h"
#import "UIView+BorderLine.h"

@interface WXYZ_AudioSoundDetailHeaderView ()
{
    UIView *contentView;
    
    UILabel *navTitleLabel;
    
    UIImageView *coverImageView;
    
    UILabel *audioTitleLabel;
    UILabel *hotLabel;
    
    UIImageView *authorIcon;
    UILabel *authorLabel;
    UILabel *collectNumLabel;
    
    WXYZ_CustomButton *collectButton;

    UILabel *tagView;

    UIView *introductionView;
    UILabel *introductionLabel;
    WXYZ_CustomButton *moreButton;

    UIButton *vipButton;

    // 展开详情后视图样式
    UILabel *introductionBottomLabel;
    
    WXYZ_CustomButton *packUpButton;
    
    WXYZ_CustomButton *bottomPackUpButton;
    
    WXYZ_ADManager *adView;
}

@property (nonatomic, strong) YYTextView *introductionTextView;

@end

@implementation WXYZ_AudioSoundDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.alpha = 0;
    navTitleLabel.textColor = kWhiteColor;
    navTitleLabel.textAlignment = NSTextAlignmentLeft;
    navTitleLabel.font = kBoldMainFont;
    [contentView addSubview:navTitleLabel];
    
    [navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin + 44);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT - 44);
        make.width.mas_equalTo(SCREEN_WIDTH / 2 - 44);
        make.height.mas_equalTo(44);
    }];
    
    coverImageView = [[UIImageView alloc] initWithCornerRadiusAdvance:4 rectCornerType:UIRectCornerAllCorners];
    coverImageView.image = HoldImage;
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [contentView addSubview:coverImageView];
    
    [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT + kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH / 4 + kMargin);
        make.height.mas_equalTo(kGeometricHeight((SCREEN_WIDTH / 4 + kMargin), 3, 4));
    }];
    
    audioTitleLabel = [[UILabel alloc] init];
    audioTitleLabel.textColor = kWhiteColor;
    audioTitleLabel.textAlignment = NSTextAlignmentLeft;
    audioTitleLabel.font = kBoldFont22;
    [contentView addSubview:audioTitleLabel];

    [audioTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(coverImageView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(coverImageView.mas_top);
        make.right.mas_equalTo(contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(30);
    }];

    tagView = [[UILabel alloc] init];
    tagView.backgroundColor = [UIColor clearColor];
    tagView.textColor = kColorRGBA(255, 255, 255, 0.9);
    tagView.textAlignment = NSTextAlignmentLeft;
    tagView.font = kFont12;
    [contentView addSubview:tagView];

    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(audioTitleLabel.mas_left);
        make.top.mas_equalTo(audioTitleLabel.mas_bottom).with.offset(kQuarterMargin);
        make.right.mas_equalTo(audioTitleLabel.mas_right);
        make.height.mas_equalTo(25);
    }];

    hotLabel = [[UILabel alloc] init];
    hotLabel.backgroundColor = [UIColor clearColor];
    hotLabel.textColor = kColorRGBA(255, 255, 255, 0.9);
    hotLabel.textAlignment = NSTextAlignmentLeft;
    hotLabel.font = kFont12;
    [contentView addSubview:hotLabel];

    [hotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(audioTitleLabel.mas_left);
        make.top.mas_equalTo(tagView.mas_bottom);
        make.right.mas_equalTo(audioTitleLabel.mas_right);
        make.height.mas_equalTo(tagView.mas_height);
    }];

    collectNumLabel = [[UILabel alloc] init];
    collectNumLabel.backgroundColor = [UIColor clearColor];
    collectNumLabel.textColor = kColorRGBA(255, 255, 255, 0.9);
    collectNumLabel.textAlignment = NSTextAlignmentLeft;
    collectNumLabel.font = kFont12;
    [contentView addSubview:collectNumLabel];

    [collectNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(audioTitleLabel.mas_left);
        make.top.mas_equalTo(hotLabel.mas_bottom);
        make.right.mas_equalTo(audioTitleLabel.mas_right);
        make.height.mas_equalTo(tagView.mas_height);
    }];

    collectButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectMake(1, 1, 1, 1) buttonTitle:@"收藏" buttonImageName:@"audio_collection_heart" buttonIndicator:WXYZ_CustomButtonIndicatorTitleRight];
    collectButton.buttonImageScale = 0.4;
    collectButton.buttonTitleFont = kFont12;
    collectButton.graphicDistance = 2;
    collectButton.buttonTitleColor = kWhiteColor;
    collectButton.hidden = YES;
    collectButton.layer.cornerRadius = 14;
    collectButton.clipsToBounds = YES;
    [collectButton addTarget:self action:@selector(collectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:collectButton];

    [collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(contentView.mas_right).with.offset(- kMargin);
        make.bottom.mas_equalTo(coverImageView.mas_bottom);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(80);
    }];

    authorIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_detail_author"]];
    authorIcon.hidden = YES;
    [contentView addSubview:authorIcon];

    [authorIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(collectNumLabel.mas_left);
        make.bottom.mas_equalTo(coverImageView.mas_bottom).with.offset(- 2);
        make.width.height.mas_equalTo(20);
    }];

    authorLabel = [[UILabel alloc] init];
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.textColor = kWhiteColor;
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.font = kMainFont;
    [contentView addSubview:authorLabel];

    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(authorIcon.mas_right).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(authorIcon.mas_bottom);
        make.right.mas_equalTo(collectButton.mas_left).with.offset(- kHalfMargin);
        make.height.mas_equalTo(authorIcon.mas_height);
    }];

    introductionView = [[UIView alloc] init];
    introductionView.backgroundColor = kColorRGBA(0, 0, 0, 0.2);
    introductionView.layer.cornerRadius = 6;
    introductionView.hidden = YES;
    introductionView.userInteractionEnabled = YES;
    [contentView addSubview:introductionView];

    introductionLabel = [[UILabel alloc] init];
    introductionLabel.textColor = kColorRGBA(255, 255, 255, 0.9);
    introductionLabel.font = kFont12;
    introductionLabel.backgroundColor = [UIColor clearColor];
    introductionLabel.numberOfLines = 0;
    introductionLabel.userInteractionEnabled = YES;
    [contentView addSubview:introductionLabel];

    [introductionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin + kHalfMargin);
        make.right.mas_equalTo(contentView.mas_right).with.offset(- kMargin - kHalfMargin);
        make.top.mas_equalTo(coverImageView.mas_bottom).with.offset(kMargin + kHalfMargin);
        make.height.mas_equalTo(80);
    }];

    [introductionView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(introductionLabel.mas_left).with.offset(- kHalfMargin);
       make.right.mas_equalTo(introductionLabel.mas_right).with.offset(kHalfMargin);
       make.top.mas_equalTo(introductionLabel.mas_top).with.offset(- kQuarterMargin);
       make.bottom.mas_equalTo(introductionLabel.mas_bottom).with.offset(kQuarterMargin);
    }];

    moreButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"展开简介" buttonImageName:@"public_down_arrow" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    moreButton.buttonTitleFont = kFont10;
    moreButton.buttonImageScale = 0.5;
    moreButton.graphicDistance = 3;
    moreButton.buttonTintColor = kWhiteColor;
    moreButton.backgroundColor = kColorRGBA(255, 255, 255, 0.2);
    moreButton.layer.cornerRadius = 10;
    [moreButton addTarget:self action:@selector(spreadClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:moreButton];

    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(introductionLabel.mas_right).with.offset(- kQuarterMargin);
        make.bottom.mas_equalTo(introductionLabel.mas_bottom).with.offset(- 2.5);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(20);
    }];

    vipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    vipButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    vipButton.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
    [vipButton setImage:[UIImage imageNamed:@"audio_detail_member"] forState:UIControlStateNormal];
    [vipButton addTarget:self action:@selector(vipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:vipButton];

    [vipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(introductionView.mas_bottom).with.offset(kMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - 2 * kMargin);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    
    adView = [[WXYZ_ADManager alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - kMargin * 2, kGeometricHeight(SCREEN_WIDTH - kMargin * 2, 3, 1)) adType:WXYZ_ADViewTypeNone adPosition:WXYZ_ADViewPositionNone];
    adView.backgroundColor = [UIColor clearColor];
    adView.userInteractionEnabled = YES;
    [contentView addSubview:adView];
    
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - 2 * kMargin);
        make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, 3, 1));
        make.top.mas_equalTo(vipButton.mas_bottom).with.offset(kMargin);
        make.bottom.mas_equalTo(contentView.mas_bottom).with.offset(- kMargin).priorityLow();
    }];
    
    // 展开详情后视图
    introductionBottomLabel = [[UILabel alloc] init];
    introductionBottomLabel.text = @"简介";
    introductionBottomLabel.textColor = kWhiteColor;
    introductionBottomLabel.textAlignment = NSTextAlignmentLeft;
    introductionBottomLabel.font = kBoldFont22;
    introductionBottomLabel.alpha = 0;
    [contentView addSubview:introductionBottomLabel];
    
    [introductionBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(coverImageView.mas_bottom).with.offset(kMargin);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(30);
    }];
    
    packUpButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"收起简介" buttonImageName:@"public_down_arrow" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    packUpButton.alpha = 0;
    packUpButton.transformImageView = YES;
    packUpButton.buttonTitleFont = kFont10;
    packUpButton.buttonImageScale = 0.5;
    packUpButton.graphicDistance = 3;
    packUpButton.buttonTintColor = kWhiteColor;
    packUpButton.backgroundColor = kColorRGBA(255, 255, 255, 0.2);
    packUpButton.layer.cornerRadius = 10;
    [packUpButton addTarget:self action:@selector(packUpClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:packUpButton];

    [packUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(introductionBottomLabel.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(20);
    }];
    
    self.introductionTextView = [[YYTextView alloc] init];
    self.introductionTextView.editable = NO;
    self.introductionTextView.textColor = kWhiteColor;
    self.introductionTextView.font = kMainFont;
    self.introductionTextView.alpha = 0;
    self.introductionTextView.showsVerticalScrollIndicator = NO;
    self.introductionTextView.showsHorizontalScrollIndicator = NO;
    [contentView addSubview:self.introductionTextView];
    
    [self.introductionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(introductionBottomLabel.mas_left);
        make.right.mas_equalTo(packUpButton.mas_right);
        make.top.mas_equalTo(introductionBottomLabel.mas_bottom).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(contentView.mas_bottom).priorityLow();
    }];
    
    bottomPackUpButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"点击收起" buttonImageName:@"public_down_arrow" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    bottomPackUpButton.alpha = 0;
    bottomPackUpButton.transformImageView = YES;
    bottomPackUpButton.buttonTitleFont = kMainFont;
    bottomPackUpButton.buttonImageScale = 0.4;
    bottomPackUpButton.graphicDistance = 5;
    bottomPackUpButton.buttonTintColor = kWhiteColor;
    bottomPackUpButton.backgroundColor = kBlackTransparentColor;
    bottomPackUpButton.layer.cornerRadius = 20;
    [bottomPackUpButton addTarget:self action:@selector(packUpClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:bottomPackUpButton];
    
    [bottomPackUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(contentView.mas_centerX);
        make.bottom.mas_equalTo(contentView.mas_bottom).with.offset(- 2 * kMargin);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(40);
    }];

}

- (void)setAudioModel:(WXYZ_ProductionModel *)audioModel
{
    _audioModel = audioModel;
    
    collectButton.hidden = NO;
    
    [coverImageView setImageWithURL:[NSURL URLWithString:audioModel.cover] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    navTitleLabel.text = audioModel.name?:@"";
    audioTitleLabel.text = audioModel.name?:@"";
    hotLabel.text = audioModel.hot_num?:@"";
    collectNumLabel.text = audioModel.total_favors?:@"";
    
    authorIcon.hidden = NO;
    authorLabel.text = audioModel.author.length > 0 ?audioModel.author:@"--";
    
    NSMutableArray *tagArray = [NSMutableArray array];
    for (WXYZ_TagModel *tagModel in audioModel.tag) {
        [tagArray addObject:tagModel.tab];
    }
    tagView.text = [tagArray componentsJoinedByString:@"|"]?:@"";
    
    [self reloadCollectionButtonState];

    [vipButton mas_updateConstraints:^(MASConstraintMaker *make) {
        if ([WXYZ_UserInfoManager shareInstance].isVip) {
            make.top.mas_equalTo(introductionView.mas_bottom).with.offset(CGFLOAT_MIN);
            make.height.mas_equalTo(CGFLOAT_MIN);
        } else if (!audioModel.is_baoyue) {
            make.top.mas_equalTo(introductionView.mas_bottom).with.offset(CGFLOAT_MIN);
            make.height.mas_equalTo(CGFLOAT_MIN);
        } else {
            make.top.mas_equalTo(introductionView.mas_bottom).with.offset(kMargin);
            make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - 2 * kMargin, 800, 90));
        }
    }];
    
    adView.adModel = audioModel;
    [adView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (audioModel.ad_type == 0) {
            make.top.mas_equalTo(vipButton.mas_bottom).with.offset(CGFLOAT_MIN);
            make.height.mas_equalTo(CGFLOAT_MIN);
        } else {
            make.top.mas_equalTo(vipButton.mas_bottom).with.offset(kMargin);
            make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, audioModel.ad_width?:3, audioModel.ad_height?:1));
        }
    }];
    
    [introductionBottomLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (audioModel.ad_type == 0) {
            make.top.mas_equalTo(coverImageView.mas_bottom).with.offset(kMargin);
        } else {
            make.top.mas_equalTo(coverImageView.mas_bottom).with.offset(kHalfMargin + kMargin + kGeometricHeight(SCREEN_WIDTH - kMargin, audioModel.ad_width?:3, audioModel.ad_height?:1));
        }
    }];
    
    introductionView.hidden = NO;
    {
        if (audioModel.production_descirption.length > 0) {
            // 截取简介
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:audioModel.production_descirption?:@""];
            attributedString.lineSpacing = 6;
            attributedString.font = kFont12;
            attributedString.color = kWhiteColor;
            
            NSAttributedString *separatedString = [WXYZ_ViewHelper getSubContentWithOriginalContent:attributedString labelWidth:(SCREEN_WIDTH - 2 * (kMargin + kHalfMargin + kQuarterMargin)) labelMaxLine:2];
            introductionLabel.attributedText = separatedString;
            [introductionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(coverImageView.mas_bottom).with.offset(kMargin + kHalfMargin);
                make.height.mas_equalTo([WXYZ_ViewHelper boundsWithFont:kFont12 attributedText:separatedString needWidth:(SCREEN_WIDTH - 2 * (kMargin + kHalfMargin)) lineSpacing:6] + kHalfMargin);
            }];
            
            [introductionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(introductionLabel.mas_top).with.offset(- kQuarterMargin);
                make.bottom.mas_equalTo(introductionLabel.mas_bottom).with.offset(kQuarterMargin);
            }];
            
            moreButton.hidden = NO;
        } else {
            
            moreButton.hidden = YES;
            
            [introductionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(coverImageView.mas_bottom).with.offset(CGFLOAT_MIN);
                make.height.mas_equalTo(CGFLOAT_MIN);
            }];
            
            [introductionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(introductionLabel.mas_top).with.offset(CGFLOAT_MIN);
                make.bottom.mas_equalTo(introductionLabel.mas_bottom).with.offset(CGFLOAT_MIN);
            }];
        }
    }
    
    
    NSMutableAttributedString __block *attributedString = [[NSMutableAttributedString alloc] initWithString:audioModel.production_descirption?:@""];
    attributedString.lineSpacing = 8;
    attributedString.font = kMainFont;
    attributedString.color = kWhiteColor;
    [attributedString appendString:@"\n"];
    
    if (audioModel.horizontal_cover.length > 0) {
        WS(weakSelf)
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:audioModel.horizontal_cover?:@""]  options:YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                YYAnimatedImageView *imageView = nil;
                if (image) {
                    imageView = [[YYAnimatedImageView alloc] initWithImage:image];
                    imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 2 * kMargin, kGeometricHeight(SCREEN_WIDTH - 2 * kMargin, image.size.width, image.size.height));
                }
                NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeScaleAspectFit attachmentSize:imageView.frame.size alignToFont:kMainFont alignment:YYTextVerticalAlignmentCenter];
                [attributedString appendAttributedString:attachText];
                
                weakSelf.introductionTextView.attributedText = attributedString;
            });
        }];
    } else {
        self.introductionTextView.attributedText = attributedString;
    }
    
    [self layoutIfNeeded];

    if (self.changeIntroductionBlock) {
        if ([[WXYZ_UserInfoManager shareInstance] isVip] || !audioModel.is_baoyue) {
            self.changeIntroductionBlock(adView.bottom + kHalfMargin, YES);
        } else {
            self.changeIntroductionBlock(adView.bottom + kHalfMargin, YES);
        }
    }
}

- (void)setContentOffSetY:(CGFloat)contentOffSetY
{
    _contentOffSetY = contentOffSetY;
    
    if (contentOffSetY < self.bottom - PUB_NAVBAR_HEIGHT) {
        navTitleLabel.alpha = 0;
        [collectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(contentView.mas_right).with.offset(- kMargin);
            make.bottom.mas_equalTo(coverImageView.mas_bottom);
            make.height.mas_equalTo(28);
            make.width.mas_equalTo(80);
        }];
    } else if (contentOffSetY > 0){
        navTitleLabel.alpha = 1;
        [collectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
#if WX_Download_Mode && (WX_W_Share_Mode || WX_Q_Share_Mode)
            make.right.mas_equalTo(contentView.mas_right).with.offset(- 2 * kHalfMargin - kMargin - 2 * 30);
#elif WX_Download_Mode || WX_W_Share_Mode || WX_Q_Share_Mode
            make.right.mas_equalTo(contentView.mas_right).with.offset(- kHalfMargin - kMargin - 30);
#else
            make.right.mas_equalTo(contentView.mas_right).with.offset(- kMargin);
#endif
            make.centerY.mas_equalTo(navTitleLabel.mas_centerY);
            make.height.mas_equalTo(28);
            make.width.mas_equalTo(80);
        }];
    }
    
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCollectedWithProductionModel:self.audioModel]) {
        [collectButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont12 labelHeight:28 labelText:collectButton.buttonTitle] + 20);
            }];
        
    } else {
        [collectButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont12 labelHeight:28 labelText:collectButton.buttonTitle] + 30);
        }];
    }
    
    [contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).with.offset(contentOffSetY);
        make.height.mas_equalTo(self.mas_height).with.offset(contentOffSetY);
    }];
}

// 展开详情
- (void)spreadClick
{
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        moreButton.alpha = 0;
        introductionLabel.alpha = 0;
        introductionView.alpha = 0;
        vipButton.alpha = 0;
        
        packUpButton.alpha = 1;
        bottomPackUpButton.alpha = 1;
        introductionBottomLabel.alpha = 1;
        self.introductionTextView.alpha = 1;
    }];
    
    [adView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.width.mas_equalTo(SCREEN_WIDTH - 2 * kMargin);
        if (self.audioModel.ad_type == 0) {
            make.height.mas_equalTo(CGFLOAT_MIN);
        } else {
            make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, self.audioModel.ad_width?:3, self.audioModel.ad_height?:1));
        }
        make.top.mas_equalTo(coverImageView.mas_bottom).with.offset(kMargin);
        make.bottom.mas_equalTo(contentView.mas_bottom).with.offset(- kMargin).priorityLow();
    }];
    
    if (self.changeIntroductionBlock) {
        self.changeIntroductionBlock(SCREEN_HEIGHT, NO);
    }
}

// 收起详情
- (void)packUpClick
{
    packUpButton.alpha = 0;
    bottomPackUpButton.alpha = 0;
    
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        moreButton.alpha = 1;
        introductionLabel.alpha = 1;
        introductionView.alpha = 1;
        vipButton.alpha = 1;
        
        introductionBottomLabel.alpha = 0;
        self.introductionTextView.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (self.changeIntroductionBlock) {
            self.changeIntroductionBlock(adView.bottom + kHalfMargin, YES);            
        }
    }];
    
    [adView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
            make.left.mas_equalTo(kMargin);
            make.width.mas_equalTo(SCREEN_WIDTH - 2 * kMargin);
            if (self.audioModel.ad_type == 0) {
                make.top.mas_equalTo(vipButton.mas_bottom).with.offset(CGFLOAT_MIN);
                make.height.mas_equalTo(CGFLOAT_MIN);
            } else {
                make.top.mas_equalTo(vipButton.mas_bottom).with.offset(kMargin);
                make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, self.audioModel.ad_width?:3, self.audioModel.ad_height?:1));
            }
        make.bottom.mas_equalTo(contentView.mas_bottom).with.offset(- kMargin).priorityLow();
    }];
    
}

- (void)vipButtonClick
{
    WS(weakSelf)
    WXYZ_MemberViewController *vc = [[WXYZ_MemberViewController alloc] init];
    vc.paySuccessBlock = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Audio_Check_Recommend object:[WXYZ_UtilsHelper formatStringWithInteger:[[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] getReadingRecordChapter_idWithProduction_id:weakSelf.audioModel.production_id]]];
    };
    [[WXYZ_ViewHelper getWindowRootController] presentViewController:vc animated:YES completion:nil];
}

- (void)collectionButtonClick:(WXYZ_CustomButton *)sender
{
    if (![[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCollectedWithProductionModel:self.audioModel]) {
        [[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] addCollectionWithProductionModel:self.audioModel];
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"已收藏"];
        [self reloadCollectionButtonState];
    }
    
    [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.audioModel.production_id productionType:WXYZ_ProductionTypeAudio complete:nil];
}

- (void)reloadCollectionButtonState
{
    if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCollectedWithProductionModel:self.audioModel]) {
        collectButton.buttonImageScale = 0;
        collectButton.buttonTitle = @"已收藏";
        collectButton.horizontalMigration = - 3;
        [collectButton selectBackgroundColor];
        collectButton.tag = 2;
        
        [collectButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont12 labelHeight:28 labelText:collectButton.buttonTitle] + 20);
        }];
    } else {
        collectButton.buttonImageScale = 0.4;
        collectButton.buttonTitle = @"收藏";
        collectButton.horizontalMigration = 0;
        [collectButton normalBackgroundColor];
        collectButton.tag = 1;
        
        [collectButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont12 labelHeight:28 labelText:collectButton.buttonTitle] + 30);
        }];
    }
}

@end
