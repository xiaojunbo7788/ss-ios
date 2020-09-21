//
//  WXYZ_BasicComicCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BasicComicCollectionViewCell.h"
#import "WXYZ_ComicNormalVerticalCollectionViewCell.h"

@implementation WXYZ_BasicComicCollectionViewCell

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
    self.comicCoverView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeComic productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    [self addSubview:self.comicCoverView];
    
    [self.comicCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(Comic_NormalVertical_Width);
        make.height.mas_equalTo(Comic_NormalVertical_Height);
    }];
    
    self.comicNameLabel = [[UILabel alloc] init];
    self.comicNameLabel.textColor = kBlackColor;
    self.comicNameLabel.textAlignment = NSTextAlignmentLeft;
    self.comicNameLabel.font = kMainFont;
    self.comicNameLabel.numberOfLines = 1;
    [self addSubview:self.comicNameLabel];
    
    [self.comicNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(kQuarterMargin);
        make.top.mas_equalTo(self.comicCoverView.mas_bottom).with.offset(kQuarterMargin);
        make.right.mas_equalTo(self.mas_right).with.offset(- kQuarterMargin);
        make.height.mas_equalTo(Comic_Cell_Title_Height / 2);
    }];
    
    self.comicDesLabel = [[UILabel alloc] init];
    self.comicDesLabel.textColor = kGrayTextColor;
    self.comicDesLabel.textAlignment = NSTextAlignmentLeft;
    self.comicDesLabel.font = kFont12;
    self.comicDesLabel.numberOfLines = 1;
    [self addSubview:self.comicDesLabel];
    
    [self.comicDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.comicNameLabel.mas_left);
        make.top.mas_equalTo(self.comicNameLabel.mas_bottom);
        make.right.mas_equalTo(self.comicNameLabel.mas_right);
        make.height.mas_equalTo(self.comicNameLabel.mas_height);
    }];
}

- (void)setComicListModel:(WXYZ_ProductionModel *)comicListModel
{
    if (!comicListModel) {
        return;
    }
    
    _comicListModel = comicListModel;
    
    self.comicCoverView.coverTitleString = comicListModel.flag?:@"";
    
    self.comicNameLabel.text = comicListModel.name?:@"";
}

@end
