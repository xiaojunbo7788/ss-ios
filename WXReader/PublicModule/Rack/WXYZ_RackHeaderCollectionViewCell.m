//
//  WXYZ_RackHeaderCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/13.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_RackHeaderCollectionViewCell.h"

@implementation WXYZ_RackHeaderCollectionViewCell
{
    UIView *bottomView;
    
    WXYZ_ProductionCoverView *bookImageView;
    
    UILabel *bookTitleLabel;
    YYLabel *bookDetailLabel;
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
    bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = kGrayViewColor;
    bottomView.layer.cornerRadius = 8;
    [self addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin + kQuarterMargin);
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin - kQuarterMargin);
        make.top.mas_equalTo(self.mas_top).with.offset(kHalfMargin);
        make.height.mas_equalTo(self.mas_height).with.offset(- kMargin);
    }];
    
    bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    [bottomView addSubview:bookImageView];
    
    [bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bottomView.mas_left).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(bottomView.mas_centerY);
        make.height.mas_equalTo(bottomView.mas_height).with.offset(- kMargin);
        make.width.mas_equalTo(kGeometricWidth((self.height - 2 * kMargin), 3, 4));
    }];
    
    bookTitleLabel = [[UILabel alloc] init];
    bookTitleLabel.textColor = kBlackColor;
    bookTitleLabel.textAlignment = NSTextAlignmentLeft;
    bookTitleLabel.numberOfLines = 1;
    bookTitleLabel.font = kMainFont;
    [self addSubview:bookTitleLabel];
    
    [bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookImageView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(bookImageView.mas_top).with.offset(kQuarterMargin);
        make.right.mas_equalTo(bottomView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(30);
    }];
    
    bookDetailLabel = [[YYLabel alloc] init];
    bookDetailLabel.textColor = kGrayTextColor;
    bookDetailLabel.textAlignment = NSTextAlignmentLeft;
    bookDetailLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    bookDetailLabel.numberOfLines = 2;
    bookDetailLabel.font = kFont13;
    [self addSubview:bookDetailLabel];
    
    [bookDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookTitleLabel.mas_left);
        make.top.mas_equalTo(bookTitleLabel.mas_bottom);
        make.bottom.mas_equalTo(bookImageView.mas_bottom).with.offset(- kHalfMargin);
        make.right.mas_equalTo(bookTitleLabel.mas_right);
    }];
    
}

- (void)setProductionModel:(WXYZ_ProductionModel *)productionModel
{
    _productionModel = productionModel;
    
    if (productionModel.vertical_cover.length > 0) {
        bookImageView.coverImageURL = productionModel.vertical_cover;
    } else if (productionModel.horizontal_cover.length > 0) {
        bookImageView.coverImageURL = productionModel.horizontal_cover;
    } else {
        bookImageView.coverImageURL = productionModel.cover;
    }
    
    bookTitleLabel.text = productionModel.name?:@"";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: productionModel.production_descirption?:@""];
    attributedString.lineSpacing = 3;
    attributedString.font = kFont13;
    attributedString.color = kGrayTextColor;
    bookDetailLabel.attributedText = attributedString;
}

- (void)setProductionType:(WXYZ_ProductionType)productionType
{
    _productionType = productionType;
    bookImageView.productionType = productionType;
}

@end
