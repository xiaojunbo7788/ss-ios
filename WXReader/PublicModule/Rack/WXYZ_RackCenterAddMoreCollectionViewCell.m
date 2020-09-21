//
//  WXYZ_RackCenterAddMoreCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/10/27.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_RackCenterAddMoreCollectionViewCell.h"

@implementation WXYZ_RackCenterAddMoreCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    UIView *borderView = [[UIView alloc] init];
    borderView.backgroundColor = kGrayViewColor;
    borderView.layer.cornerRadius = 2;
    [self addSubview:borderView];
    
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(BOOK_WIDTH);
        make.height.mas_equalTo(BOOK_HEIGHT);
    }];
    
    UIImageView *addImageView = [[UIImageView alloc] init];
    addImageView.image = [UIImage imageNamed:@"public_rack_add"];
    [borderView addSubview:addImageView];
    
    [addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(borderView.mas_centerX);
        make.centerY.mas_equalTo(borderView.mas_centerY);
        make.height.width.mas_equalTo(30);
    }];
}

- (void)startEditState
{
    self.hidden = YES;
}

- (void)endEditState
{
    self.hidden = NO;
}

@end
