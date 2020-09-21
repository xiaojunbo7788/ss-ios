//
//  WXYZ_AnnouncementViewCollectionViewCell.m
//  GKADRollingView
//
//  Created by Gao on 2017/2/16.
//  Copyright © 2017年 gao. All rights reserved.
//

#import "WXYZ_AnnouncementViewCollectionViewCell.h"

@interface WXYZ_AnnouncementViewCollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *headerImg;

@end

@implementation WXYZ_AnnouncementViewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = _textFont?:kFont12;
    _titleLabel.textColor = _textColor?:[UIColor blackColor];
    _titleLabel.numberOfLines = 1;
    [self addSubview:_titleLabel];
    
    _headerImg = [[UIImageView alloc] init];
    [_headerImg setImage:[[UIImage imageNamed:@"rack_notice"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _headerImg.tintColor = kMainColor;
    [self addSubview:_headerImg];
    
    [_headerImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(self.mas_height);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImg.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(self.mas_bottom);
#if WX_Sign_Mode
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin - 100);
#else
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
#endif
    }];
}


- (void)setAnnouncementModel:(WXYZ_AnnouncementModel *)announcementModel
{
    _announcementModel = announcementModel;
    
    _titleLabel.text = announcementModel.title;
}

- (void)setTextColor:(UIColor *)textColor {
    _titleLabel.textColor = textColor;
}

- (void)setIsCenter:(BOOL)isCenter {
    if (isCenter) {
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        _headerImg.hidden = YES;
    }
}

@end
