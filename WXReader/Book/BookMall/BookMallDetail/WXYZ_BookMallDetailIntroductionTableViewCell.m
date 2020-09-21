//
//  WXYZ_BookMallDetailIntroductionTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/8/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookMallDetailIntroductionTableViewCell.h"

@implementation WXYZ_BookMallDetailIntroductionTableViewCell
{
    UILabel *bookDescriptionLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    // 简介
    bookDescriptionLabel = [[UILabel alloc] init];
    bookDescriptionLabel.backgroundColor = [UIColor whiteColor];
    bookDescriptionLabel.textColor = kBlackColor;
    bookDescriptionLabel.textAlignment = NSTextAlignmentLeft;
    bookDescriptionLabel.font = kMainFont;
    bookDescriptionLabel.numberOfLines = 0;
    [self.contentView addSubview:bookDescriptionLabel];
    
    [bookDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.top).with.offset(0);
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(50);
    }];
}

- (void)setBookModel:(WXYZ_ProductionModel *)bookModel
{
    if (bookModel && (_bookModel != bookModel)) {
        _bookModel = bookModel;
        
        // 截取简介
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:bookModel.production_descirption?:@""];
        attributedString.lineSpacing = 5;
        attributedString.font = kFont12;
        attributedString.color = kGrayTextColor;
        
        NSAttributedString *separatedString = [WXYZ_ViewHelper getSubContentWithOriginalContent:attributedString labelWidth:(SCREEN_WIDTH - 2 * (kMargin + kHalfMargin)) labelMaxLine:4];
        bookDescriptionLabel.attributedText = separatedString;
        [bookDescriptionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([WXYZ_ViewHelper boundsWithFont:kFont12 attributedText:separatedString needWidth:(SCREEN_WIDTH - 2 * (kMargin + kHalfMargin)) lineSpacing:6] + kHalfMargin);
        }];
    }
}

@end
