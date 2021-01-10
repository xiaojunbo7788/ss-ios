//
//  YJMallCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "YJMallCollectionViewCell.h"
#import "UIView+AZGradient.h"

@implementation YJMallCollectionViewCell
{
    UIImageView *backHoldImageView;
    UIView *backFrostedGlassView;
    
    YYAnimatedImageView *bannerImageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    backHoldImageView = [[UIImageView alloc] init];
    backHoldImageView.clipsToBounds = YES;
    backHoldImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:backHoldImageView];
    
    [backHoldImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    backFrostedGlassView = [[UIView alloc] init];
    [self addSubview:backFrostedGlassView];
    
    [backFrostedGlassView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    bannerImageView = [[YYAnimatedImageView alloc] init];
    bannerImageView.layer.cornerRadius = 4;
    bannerImageView.clipsToBounds = YES;
    bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:bannerImageView];
    
    [bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin + kQuarterMargin);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH - 2 * (kHalfMargin + kQuarterMargin));
        make.height.mas_equalTo(kGeometricHeight((SCREEN_WIDTH - 2 * (kHalfMargin + kQuarterMargin)), 5, 3));
    }];
    
    
}

- (void)setBannerModel:(WXYZ_BannerModel *)bannerModel
{
    _bannerModel = bannerModel;
    
    if (!bannerModel) {
        return;
    }
    @try {
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:bannerModel.image?:@""]  options:YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->backHoldImageView.image = image;
                [self->backFrostedGlassView az_setGradientBackgroundWithColors:@[[UIColor whiteColor], [[UIColor colorWithHexString:bannerModel.color?:@"#000000"] colorWithAlphaComponent:0.8]] locations:nil startPoint:CGPointMake(1.0, 1.0) endPoint:CGPointMake(1.0, 0.0)];
                
            });
        }];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    [bannerImageView setImageWithURL:[NSURL URLWithString:bannerModel.image?:@""] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
}

@end
