//
//  WXYZ_BookMallBasicModuleCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/6/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookMallBasicModuleCollectionViewCell.h"

@implementation WXYZ_BookMallBasicModuleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kWhiteColor;
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    // 图片
    self.productionImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    self.productionImageView.userInteractionEnabled = YES;
    [self addSubview:self.productionImageView];
    
    [self.productionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(kHalfMargin);
        make.width.mas_equalTo(BOOK_WIDTH - 10);
        make.height.mas_equalTo(kGeometricHeight(BOOK_WIDTH - 10, 3, 4));
        make.bottom.mas_equalTo(self.mas_bottom).priorityLow();
    }];
    
    // 书名
    self.bookTitleLabel = [[UILabel alloc] init];
    self.bookTitleLabel.numberOfLines = 1;
    self.bookTitleLabel.backgroundColor = kWhiteColor;
    self.bookTitleLabel.font = kMainFont;
    self.bookTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.bookTitleLabel];
    
    [self.bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.productionImageView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.productionImageView.mas_top);
        make.right.mas_equalTo(self.mas_right);
        make.height.mas_equalTo(BOOK_CELL_TITLE_HEIGHT / 2);
    }];
    
    // 子标题
    self.bookSubTitleLabel = [[UILabel alloc] init];
    self.bookSubTitleLabel.textColor = kGrayTextColor;
    self.bookSubTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.bookSubTitleLabel.font = kFont11;
    self.bookSubTitleLabel.numberOfLines = 1;
    self.bookSubTitleLabel.hidden = YES;
    [self addSubview:self.bookSubTitleLabel];
    
    [self.bookSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bookTitleLabel.mas_left);
        make.top.mas_equalTo(self.bookTitleLabel.mas_bottom);
        make.right.mas_equalTo(self.bookTitleLabel.mas_right);
        make.height.mas_equalTo(self.bookTitleLabel.mas_height);
        make.bottom.mas_equalTo(self.mas_bottom).priorityLow();
    }];
    
    // 横线
    self.cellLine = [[UIView alloc] init];
    self.cellLine.hidden = YES;
    self.cellLine.backgroundColor = kGrayLineColor;
    [self addSubview:self.cellLine];
    
    [self.cellLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(self.mas_bottom).with.offset(- kCellLineHeight);
        make.right.mas_equalTo(self.mas_right).with.offset(kHalfMargin);
        make.height.mas_equalTo(kCellLineHeight);
    }];
}

- (void)setLabelListModel:(WXYZ_ProductionModel *)labelListModel
{
    _labelListModel = labelListModel;
    
    if (!labelListModel) {
        return;
    }
    
    self.productionImageView.coverImageURL = labelListModel.cover;
    self.productionImageView.productionType = labelListModel.productionType;
    
    self.bookTitleLabel.text = labelListModel.name?:@"";
}

- (void)setHiddenEndLine:(BOOL)hiddenEndLine
{
    _hiddenEndLine = hiddenEndLine;
    self.cellLine.hidden = hiddenEndLine;
}

- (void)setCellIndexPath:(NSIndexPath *)cellIndexPath
{
    _cellIndexPath = cellIndexPath;
}

@end
