//
//  WXYZ_ProductionCoverView.m
//  WXReader
//
//  Created by Andrew on 2020/7/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ProductionCoverView.h"

@implementation WXYZ_ProductionCoverView
{
    // 通用
    UIView *productionShadow;
    UIImageView *productionImageView;
    
    // 漫画
    UIImageView *coverBottomTitleImageView;
    UILabel *coverBottomTitleLabel;
    UIView *coverLockView;
    UIImageView *coverLockIcon;
    
    // 有声
    UIImageView *productionConnerImageView;
    
    WXYZ_ProductionType _productionType;
    WXYZ_ProductionCoverDirection _productionCoverDirection;
}

- (instancetype)initWithProductionType:(WXYZ_ProductionType)productionType productionCoverDirection:(WXYZ_ProductionCoverDirection)productionCoverDirection
{
    if (self = [super init]) {
        
        _productionType = productionType;
        _productionCoverDirection = productionCoverDirection;
        
        [self createSubview];
    }
    return self;
}

- (void)createSubview
{
    // 背景阴影
    productionShadow = [[UIView alloc] init];
    productionShadow.backgroundColor = [UIColor whiteColor];
    productionShadow.layer.shadowColor = [UIColor blackColor].CGColor;
    productionShadow.layer.shadowOffset = CGSizeMake(0, 0);
    productionShadow.layer.shadowOpacity = 0.2f;
    productionShadow.layer.shadowRadius = 2.0f;
    productionShadow.userInteractionEnabled = YES;
    [self addSubview:productionShadow];
    
    // 作品图片
    productionImageView = [[UIImageView alloc] init];
    productionImageView.contentMode = UIViewContentModeScaleAspectFill;
    productionImageView.clipsToBounds = YES;
    productionImageView.userInteractionEnabled = YES;
    [self addSubview:productionImageView];
    [self resetDefaultHoldImage];
    
    // 有声增加左下角标志
    productionConnerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_conner_image"]];
    productionConnerImageView.userInteractionEnabled = YES;
    productionConnerImageView.hidden = (_productionType != WXYZ_ProductionTypeAudio);
    [self addSubview:productionConnerImageView];
    
    // 漫画锁标志
    coverLockView = [[UIView alloc] init];
    coverLockView.userInteractionEnabled = YES;
    coverLockView.backgroundColor = kBlackTransparentColor;
    coverLockView.hidden = YES;
    [self addSubview:coverLockView];
    
    coverLockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comic_lock"]];
    [coverLockView addSubview:coverLockIcon];
    
    // 漫画底部标题背景
    coverBottomTitleImageView = [[UIImageView alloc] init];
    coverBottomTitleImageView.hidden = YES;
    coverBottomTitleImageView.image = [UIImage imageNamed:@"comic_botton_line"];
    [self addSubview:coverBottomTitleImageView];
    
    // 漫画底部标题
    coverBottomTitleLabel = [[UILabel alloc] init];
    coverBottomTitleLabel.hidden = YES;
    coverBottomTitleLabel.textColor = [UIColor whiteColor];
    coverBottomTitleLabel.textAlignment = NSTextAlignmentRight;
    coverBottomTitleLabel.backgroundColor = [UIColor clearColor];
    coverBottomTitleLabel.font = kFont12;
    [self addSubview:coverBottomTitleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [productionShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(self.mas_width).with.offset(- 2);
        make.height.mas_equalTo(self.mas_height).with.offset(- 2);
    }];
    
    [productionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(productionShadow);
    }];
    
    [productionConnerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(productionImageView.mas_left).with.offset(kQuarterMargin);
        make.bottom.mas_equalTo(productionImageView.mas_bottom).with.offset(- kQuarterMargin);
        make.width.height.mas_equalTo(productionImageView.mas_width).with.multipliedBy(0.15);
    }];
    
    [coverLockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(productionImageView);
    }];
    
    [coverLockIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(12);
        make.centerX.mas_equalTo(coverLockView.mas_centerX);
        make.centerY.mas_equalTo(coverLockView.mas_centerY);
    }];
    
    [coverBottomTitleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(productionImageView.mas_left);
        make.bottom.mas_equalTo(productionImageView.mas_bottom);
        make.width.mas_equalTo(productionImageView.mas_width);
        make.height.mas_equalTo(40);
    }];
    
    [coverBottomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(productionImageView.mas_left);
        make.bottom.mas_equalTo(productionImageView.mas_bottom);
        make.width.mas_equalTo(productionImageView.mas_width);
        make.height.mas_equalTo(25);
    }];
}

// 重置为默认图
- (void)resetDefaultHoldImage
{
    if (_productionCoverDirection == WXYZ_ProductionCoverDirectionHorizontal) {
        productionImageView.image = HoldImage;
    }
    
    if (_productionCoverDirection == WXYZ_ProductionCoverDirectionVertical) {
        productionImageView.image = HoldImage;
    }
}

- (void)setIs_locked:(BOOL)is_locked
{
    _is_locked = is_locked;
    
    if (_productionType == WXYZ_ProductionTypeComic) {
        coverLockView.hidden = !_is_locked;
    } else {
        coverLockView.hidden = YES;
    }
}

- (void)setProductionType:(WXYZ_ProductionType)productionType
{
    _productionType = productionType;
    
    if (productionType == WXYZ_ProductionTypeAudio) {
        productionConnerImageView.hidden = NO;
    } else {
        productionConnerImageView.hidden = YES;
    }
}

- (void)setProductionCoverDirection:(WXYZ_ProductionCoverDirection)productionCoverDirection
{
    _productionCoverDirection = productionCoverDirection;
    
    [self resetDefaultHoldImage];
}

- (void)setCoverImageURL:(NSString *)coverImageURL
{
    _coverImageURL = coverImageURL;
    
    [productionImageView setImageWithURL:[NSURL URLWithString:coverImageURL?:@""] placeholder:HoldImage];
}

- (void)setCoverTitleString:(NSString *)coverTitleString
{
    _coverTitleString = coverTitleString;
    
    if (coverTitleString.length > 0) {
        coverBottomTitleImageView.hidden = NO;
        
        coverBottomTitleLabel.hidden = NO;
        coverBottomTitleLabel.text = coverTitleString;
    }
}

@end
