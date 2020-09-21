//
//  WXYZ_BookMallHorizontalModuleCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/5/22.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookMallHorizontalModuleCollectionViewCell.h"
#import "WXYZ_TagView.h"

@implementation WXYZ_BookMallHorizontalModuleCollectionViewCell
{
    UILabel *authorLabel;
    WXYZ_TagView *tagView;
    YYLabel *bookIntroductionLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    [self.productionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(BOOK_WIDTH - 10);
        make.height.mas_equalTo(kGeometricHeight(BOOK_WIDTH - 10, 3, 4));
    }];
    
    [self.bookTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.productionImageView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.productionImageView.mas_top);
        make.right.mas_equalTo(self.mas_right);
        make.height.mas_equalTo(BOOK_CELL_TITLE_HEIGHT / 2);
    }];
    
    // 作者
    authorLabel = [[UILabel alloc] init];
    authorLabel.numberOfLines = 1;
    authorLabel.backgroundColor = kWhiteColor;
    authorLabel.font = kFont11;
    authorLabel.textColor = kColorRGBA(176, 176, 177, 1);
    authorLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:authorLabel];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bookTitleLabel.mas_left);
        make.bottom.mas_equalTo(self.productionImageView.mas_bottom);
        make.width.mas_equalTo(self.bookTitleLabel.mas_width);
        make.height.mas_equalTo(self.bookTitleLabel.mas_height);
    }];
    
    // 标签
    tagView = [[WXYZ_TagView alloc] init];
    tagView.tagViewFont = kFont11;
    tagView.tagAlignment = WXYZ_TagAlignmentRight;
    tagView.tagBorderStyle = WXYZ_TagBorderStyleNone;
    [self addSubview:tagView];

    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(authorLabel.mas_centerY);
        make.right.mas_equalTo(self.bookTitleLabel.mas_right);
        make.height.mas_equalTo(authorLabel.mas_height);
        make.left.mas_equalTo(self.bookTitleLabel.mas_left);
    }];
    
    // 简介
    bookIntroductionLabel = [[YYLabel alloc] init];
    bookIntroductionLabel.numberOfLines = 3;
    bookIntroductionLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    bookIntroductionLabel.backgroundColor = kWhiteColor;
    bookIntroductionLabel.font = kFont13;
    bookIntroductionLabel.textColor = kColorRGBA(102, 102, 102, 1);
    bookIntroductionLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:bookIntroductionLabel];
    
    [bookIntroductionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bookTitleLabel.mas_left);
        make.right.mas_equalTo(self.bookTitleLabel.mas_right);
        make.top.mas_equalTo(self.bookTitleLabel.mas_bottom).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(authorLabel.mas_top).with.offset(- kHalfMargin);
    }];
}

- (void)setLabelListModel:(WXYZ_ProductionModel *)labelListModel
{
    [super setLabelListModel:labelListModel];
    
    authorLabel.text = [[labelListModel.author componentsSeparatedByString:@","] componentsJoinedByString:@" "]?:@"";
    tagView.tagArray = labelListModel.tag;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString: labelListModel.production_descirption?:@""];
    text.lineSpacing = 5;
    text.font = kFont13;
    text.color = kColorRGBA(118, 118, 118, 1);
    bookIntroductionLabel.attributedText = text;
}

@end
