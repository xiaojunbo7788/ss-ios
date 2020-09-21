//
//  WXYZ_ComicDiscoverTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/12.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDiscoverTableViewCell.h"
#import "WXYZ_TagView.h"

@implementation WXYZ_ComicDiscoverTableViewCell
{
    UIImageView *coverImageView;
    
    UILabel *titleLabel;
    UILabel *flagLabel;
    WXYZ_TagView *tagView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    coverImageView = [[UIImageView alloc] initWithCornerRadiusAdvance:8 rectCornerType:UIRectCornerAllCorners];
    coverImageView.frame = CGRectMake(kHalfMargin, kHalfMargin, SCREEN_WIDTH - kMargin, kGeometricHeight(SCREEN_WIDTH - kMargin, 7, 4));
    coverImageView.image = HoldImage;
    coverImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    coverImageView.layer.shadowOffset = CGSizeMake(0, 0);
    coverImageView.layer.shadowOpacity = 0.1f;
    coverImageView.layer.shadowRadius = 2.0f;
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [coverImageView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:coverImageView.bounds] CGPath]];
    [self.contentView addSubview:coverImageView];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = kBlackColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = kMainFont;
    [self.contentView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(coverImageView.height + kHalfMargin + kHalfMargin);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    
    // 标签
    tagView = [[WXYZ_TagView alloc] init];
    tagView.tagViewFont = kFont10;
    tagView.tagViewCornerRadius = 4;
    [self.contentView addSubview:tagView];
    
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).and.offset(kHalfMargin);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(20);
    }];
    
    flagLabel = [[UILabel alloc] init];
    flagLabel.textColor = kGrayTextColor;
    flagLabel.textAlignment = NSTextAlignmentLeft;
    flagLabel.font = kFont11;
    [self.contentView addSubview:flagLabel];
    
    [flagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_left);
        make.top.mas_equalTo(titleLabel.mas_bottom).with.offset(kQuarterMargin);
        make.right.mas_equalTo(tagView.mas_right);
        make.height.mas_equalTo(15);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kQuarterMargin).priorityLow();
    }];
}

- (void)setListModel:(WXYZ_ProductionModel *)listModel
{
    _listModel = listModel;
    
    [coverImageView setImageWithURL:[NSURL URLWithString:listModel.cover?:@""] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    titleLabel.text = listModel.name?:@"";
    [titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:titleLabel]);
    }];
    
    if (listModel.flag.length > 0) {
        flagLabel.text = listModel.flag?:@"";
        [flagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(15);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kQuarterMargin).priorityLow();
        }];
    } else {
        [flagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CGFLOAT_MIN);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
        }];
    }
    
    tagView.tagArray = listModel.tag;
}

@end
