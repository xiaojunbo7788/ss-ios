//
//  WXYZ_RackCenterCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/6/28.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_RackCenterCollectionViewCell.h"

@implementation WXYZ_RackCenterCollectionViewCell
{
    UILabel *bookTitleLabel;
    UILabel *finishedLabel;
    UIImageView *selectView;
    UIImageView *recommendConnerImageView;
    UILabel *badgeLabel;
}

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
    self.bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    self.bookImageView.userInteractionEnabled = YES;
    [self addSubview:self.bookImageView];
    
    [self.bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(BOOK_WIDTH);
        make.height.mas_equalTo(BOOK_HEIGHT);
    }];
    
    recommendConnerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_rack_recommend_conner"]];
    recommendConnerImageView.hidden = YES;
    [self.bookImageView addSubview:recommendConnerImageView];
    
    [recommendConnerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(BOOK_WIDTH / 3);
        make.height.mas_equalTo(kGeometricHeight((BOOK_WIDTH / 3), 102, 54));
    }];
    
    badgeLabel = [[UILabel alloc] init];
    badgeLabel.hidden = YES;
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    badgeLabel.textColor = kWhiteColor;
    badgeLabel.backgroundColor = kColorRGBA(229, 91, 94, 1);
    badgeLabel.font = kFont9;
    badgeLabel.numberOfLines = 1;
    badgeLabel.layer.cornerRadius = 8;
    badgeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    badgeLabel.layer.borderWidth = 2;
    badgeLabel.clipsToBounds = YES;
    [self.bookImageView addSubview:badgeLabel];
    
    [badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bookImageView.mas_right).with.offset(- 3);
        make.centerY.mas_equalTo(self.bookImageView.mas_top).with.offset(3);
        make.width.height.mas_equalTo(16);
    }];
    
    selectView = [[UIImageView alloc] init];
    selectView.hidden = YES;
    selectView.userInteractionEnabled = YES;
    selectView.image = [UIImage imageNamed:@"audio_download_unselect"];
    [self addSubview:selectView];
    
    [selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bookImageView.mas_right).with.offset(- 5);
        make.bottom.mas_equalTo(self.bookImageView.mas_bottom).with.offset(- 5);
        make.height.width.mas_equalTo(18);
    }];
    
    bookTitleLabel = [[UILabel alloc] init];
    bookTitleLabel.numberOfLines = 1;
    bookTitleLabel.backgroundColor = kGrayViewColor;
    bookTitleLabel.font = kFont12;
    bookTitleLabel.textAlignment = NSTextAlignmentLeft;
    bookTitleLabel.textColor = kBlackColor;
    [self addSubview:bookTitleLabel];
    
    [bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bookImageView.mas_left);
        make.top.mas_equalTo(self.bookImageView.mas_bottom).with.offset(kHalfMargin);
        make.width.mas_equalTo(self.bookImageView.mas_width);
        make.height.mas_equalTo(BOOK_CELL_TITLE_HEIGHT / 2);
    }];
}

- (void)setProductionModel:(WXYZ_ProductionModel *)productionModel
{
    _productionModel = productionModel;
    
    self.bookImageView.productionType = productionModel.productionType;
    
    if (productionModel.cover.length > 0) {
        self.bookImageView.coverImageURL = productionModel.cover;
    } else if (productionModel.vertical_cover.length > 0) {
        self.bookImageView.coverImageURL = productionModel.vertical_cover;
    } else if (productionModel.horizontal_cover.length > 0) {
        self.bookImageView.coverImageURL = productionModel.horizontal_cover;
    }
    
    recommendConnerImageView.hidden = !productionModel.is_recommend;
    
    bookTitleLabel.backgroundColor = kWhiteColor;
    bookTitleLabel.text = productionModel.name?:@"";
    
    badgeLabel.hidden = YES;
}

- (void)setBookSeleced:(BOOL)bookSeleced
{
    _bookSeleced = bookSeleced;
    if (bookSeleced) {
        selectView.image = [UIImage imageNamed:@"audio_download_select"];
        self.bookImageView.alpha = 1.0f;
    } else {
        selectView.image = [UIImage imageNamed:@"audio_download_unselect"];
        self.bookImageView.alpha = 0.5f;
    }
}

- (void)setBadgeNum:(NSString *)badgeNum
{
    if ([badgeNum isEqualToString:@"0"]) {
        return;
    }
    
    if (_productionModel.total_chapters == 0) {
        return;
    }
    
    badgeNum = [NSString stringWithFormat:@"%@", [WXYZ_UtilsHelper formatStringWithInteger:abs((int)_productionModel.total_chapters - [badgeNum intValue])]];
    
    if (badgeNum && ![badgeNum isEqualToString:@"0"]) {
        
        
        badgeLabel.hidden = NO;
        badgeLabel.text = badgeNum;
        if (badgeNum.length == 2) {
            [badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(21);
            }];
        } else if (badgeNum.length >= 3) {
            [badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(26);
            }];
        }
    } else {
        badgeLabel.hidden = YES;
    }
    
    _badgeNum = badgeNum;
}

- (void)setStartEditing:(BOOL)startEditing
{
    _startEditing  = startEditing;
    if (startEditing) {
        self.bookImageView.alpha = 0.5f;
        selectView.hidden = NO;
    } else {
        self.bookImageView.alpha = 1.0f;
        selectView.hidden = YES;
    }
}

@end
