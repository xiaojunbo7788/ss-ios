//
//  WXYZ_DiscoverHeaderCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/4/30.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_DiscoverHeaderCollectionViewCell.h"

@implementation WXYZ_DiscoverHeaderCollectionViewCell
{
    UIImageView *bannerImageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kWhiteColor;
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    bannerImageView = [[UIImageView alloc] initWithCornerRadiusAdvance:8 rectCornerType:UIRectCornerAllCorners];
    bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:bannerImageView];
    
    [bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(self.mas_width).with.offset(- kMargin);
        make.height.mas_equalTo(self.mas_height);
    }];
}

- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    
    [bannerImageView setImageWithURL:[NSURL URLWithString:imageURL] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
}
@end
