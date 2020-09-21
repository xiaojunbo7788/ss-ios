//
//  WXYZ_SearchBoxCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_SearchBoxCollectionViewCell.h"

@implementation WXYZ_SearchBoxCollectionViewCell
{
    UILabel *titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textColor = kBlackColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = kFont12;
        titleLabel.userInteractionEnabled = YES;
        titleLabel.numberOfLines = 1;
        titleLabel.layer.cornerRadius = 10;
        titleLabel.layer.borderWidth = 0.5;
        titleLabel.layer.borderColor = kWhiteColor.CGColor;
        titleLabel.clipsToBounds = YES;
        [self.contentView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).with.offset(kQuarterMargin);
            make.left.mas_equalTo(self.contentView.mas_left).with.offset(kQuarterMargin);
            make.width.mas_equalTo(30);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kQuarterMargin);
            make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kQuarterMargin).priorityLow();
        }];
    }
    return self;
}

- (void)setOptionModel:(WXYZ_SearchOptionListModel *)optionModel
{
    _optionModel = optionModel;
    
    titleLabel.text = optionModel.display?:@"";
    [titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:titleLabel] + kHalfMargin);
    }];
    
    if (optionModel.checked) {
        [self setSelectedState];
    } else {
        [self setNormalState];
    }
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    attributes.frame = CGRectMake(0, 0, [WXYZ_ViewHelper getDynamicWidthWithLabel:titleLabel] + kHalfMargin, self.height);
    return attributes;

}

- (void)setSelectedState
{
    titleLabel.textColor = kMainColor;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.layer.borderColor = kMainColor.CGColor;
    titleLabel.layer.borderWidth = 0.5;
}

- (void)setNormalState
{
    titleLabel.textColor = kBlackColor;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    titleLabel.layer.borderWidth = 0.5;
}

@end
