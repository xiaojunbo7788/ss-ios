//
//  WXYZ_FeedbackAddCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackAddCollectionViewCell.h"

@implementation WXYZ_FeedbackAddCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    self.backgroundColor = kGrayViewColor;
    
    UIImageView *addImage = [[UIImageView alloc] init];
    addImage.image = [UIImage imageNamed:@"public_rack_add"];
    [self addSubview:addImage];
    
    [addImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(self.mas_width).multipliedBy(0.3);
    }];
}

@end
