//
//  WXYZ_ProductionListTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ProductionListTableViewCell.h"

@interface WXYZ_ProductionListTableViewCell ()

@property (nonatomic, weak) UIImageView *indexImageView;

@property (nonatomic, weak) UILabel *indexLabel;

@end

@implementation WXYZ_ProductionListTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.backgroundColor = kWhiteColor;
    
    // 图片
    self.bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    [self.contentView addSubview:self.bookImageView];
    
    [self.bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(BOOK_WIDTH_SMALL);
        make.height.mas_equalTo(BOOK_HEIGHT_SMALL);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
    UIImageView *indexImageView = [[UIImageView alloc] init];
    indexImageView.backgroundColor = [UIColor clearColor];
    self.indexImageView = indexImageView;
    indexImageView.hidden = YES;
    indexImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.bookImageView addSubview:indexImageView];
    [indexImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bookImageView).offset(-kQuarterMargin);
        make.top.equalTo(self.bookImageView);
        make.size.mas_equalTo(CGSizeMake(24.0, 23.0));
    }];
    
    UILabel *indexLabel = [[UILabel alloc] init];
    self.indexLabel = indexLabel;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = kFont12;
    [indexImageView addSubview:indexLabel];
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(indexImageView).offset(-2.0f);
        make.centerX.equalTo(indexImageView);
    }];
    
    // 书名
    self.bookTitleLabel = [[UILabel alloc] init];
    self.bookTitleLabel.numberOfLines = 1;
    self.bookTitleLabel.backgroundColor = kWhiteColor;
    self.bookTitleLabel.font = kMainFont;
    self.bookTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.bookTitleLabel];
    
    [self.bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bookImageView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.bookImageView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(BOOK_CELL_TITLE_HEIGHT / 2);
    }];
    
    // 作者
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.numberOfLines = 1;
    self.authorLabel.backgroundColor = kWhiteColor;
    self.authorLabel.font = kFont11;
    self.authorLabel.textColor = kColorRGBA(176, 176, 177, 1);
    self.authorLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.authorLabel];
    
    [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bookTitleLabel.mas_left);
        make.bottom.mas_equalTo(self.bookImageView.mas_bottom);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(self.bookTitleLabel.mas_height);
    }];
    
    // 标签
    self.tagView = [[WXYZ_TagView alloc] init];
    self.tagView.tagAlignment = WXYZ_TagAlignmentRight;
    self.tagView.tagBorderStyle = WXYZ_TagBorderStyleNone;
    self.tagView.tagMergeAllowance = 0;
    [self.contentView addSubview:self.tagView];
    
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.authorLabel.mas_centerY);
        make.right.mas_equalTo(self.bookTitleLabel.mas_right);
        make.height.mas_equalTo(self.authorLabel.mas_height);
        make.left.mas_equalTo(self.authorLabel.mas_right).with.offset(kHalfMargin);
    }];
    
    // 简介
    self.bookIntroductionLabel = [[YYLabel alloc] init];
    self.bookIntroductionLabel.numberOfLines = 3;
    self.bookIntroductionLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    self.bookIntroductionLabel.backgroundColor = kWhiteColor;
    self.bookIntroductionLabel.font = kFont13;
    self.bookIntroductionLabel.textColor = kColorRGBA(102, 102, 102, 1);
    self.bookIntroductionLabel.textAlignment = NSTextAlignmentLeft;
    self.bookIntroductionLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:self.bookIntroductionLabel];
    
    [self.bookIntroductionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bookTitleLabel.mas_left);
        make.right.mas_equalTo(self.bookTitleLabel.mas_right);
        make.top.mas_equalTo(self.bookTitleLabel.mas_bottom).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(self.authorLabel.mas_top).with.offset(- kHalfMargin);
    }];
}

- (void)setListModel:(WXYZ_ProductionModel *)listModel
{
    _listModel = listModel;
    
    NSString *imagePath;
    switch ([listModel.display_no integerValue]) {
        case 0:
            imagePath = @"book_list_one";
            break;
        case 1:
            imagePath = @"book_list_two";
            break;
        case 2:
            imagePath = @"book_list_three";
            break;
        default:
            imagePath = @"book_list_other";
            break;
    }
    
    self.indexImageView.image = [YYImage imageNamed:imagePath];
    self.indexImageView.hidden = [listModel.display_no integerValue] > 19;
    
    if (!self.isRankList) {
        self.indexImageView.hidden = YES;
    }
    
    self.indexLabel.text = listModel.display_no ?: @"";
    
    self.bookImageView.coverImageURL = listModel.cover;
    
    self.bookTitleLabel.text = listModel.name?:@"";
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString: listModel.production_descirption?:@""];
    text.lineSpacing = 5;
    text.font = kFont13;
    text.color = kColorRGBA(118, 118, 118, 1);
    self.bookIntroductionLabel.attributedText = text;
    
    self.authorLabel.text = listModel.author?:@"";
    [self.authorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.authorLabel]);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tagView.tagArray = listModel.tag;        
    });
}

- (void)setProductionType:(WXYZ_ProductionType)productionType
{
    [super setProductionType:productionType];
    
    self.bookImageView.productionType = productionType;
}

@end
