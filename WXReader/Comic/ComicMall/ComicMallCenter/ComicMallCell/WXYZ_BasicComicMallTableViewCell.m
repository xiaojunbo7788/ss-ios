//
//  WXYZ_BasicComicMallTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BasicComicMallTableViewCell.h"
#import "WXYZ_BasicComicCollectionViewCell.h"
#import "WXYZ_ComicNormalVerticalCollectionViewCell.h"
#import "WXYZ_ComicMiddleCrossCollectionViewCell.h"
#import "WXYZ_ComicMaxCrossCollectionViewCell.h"

@implementation WXYZ_BasicComicMallTableViewCell
{
    UIImageView *mainTitleHoldView;
    WXYZ_CustomButton *moreButton;
}

- (void)createSubviews
{
    [super createSubviews];
    
    // 主标题
    _mainTitleLabel = [[UILabel alloc] init];
    _mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    _mainTitleLabel.textColor = kBlackColor;
    _mainTitleLabel.backgroundColor = kGrayViewColor;
    _mainTitleLabel.font = kBoldFont16;
    [self.contentView addSubview:_mainTitleLabel];
    
    [_mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin + kHalfMargin + kQuarterMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(kLabelHeight + kHalfMargin);
    }];
    
    moreButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"查看更多" buttonImageName:@"public_more" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    moreButton.buttonTintColor = kGrayTextLightColor;
    moreButton.graphicDistance = 5;
    moreButton.buttonImageScale = 0.35;
    moreButton.hidden = YES;
    [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:moreButton];
    
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(_mainTitleLabel.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    mainTitleHoldView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comic_label_hold"]];
    mainTitleHoldView.hidden = YES;
    [self.contentView addSubview:mainTitleHoldView];
    
    [mainTitleHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.centerY.mas_equalTo(_mainTitleLabel.mas_centerY);
        make.width.mas_equalTo(kHalfMargin + kHalfMargin);
        make.height.mas_equalTo(kHalfMargin + kHalfMargin);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = Comic_Cell_Line_Space;
    flowLayout.minimumLineSpacing = 0.01;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(Comic_NormalVertical_Width, Comic_NormalVertical_Height);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, kHalfMargin, 0, kHalfMargin);
    
    _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _mainCollectionView.scrollEnabled = NO;
    _mainCollectionView.backgroundColor = [UIColor clearColor];
    _mainCollectionView.alwaysBounceVertical = NO;
    _mainCollectionView.showsVerticalScrollIndicator = NO;
    _mainCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:_mainCollectionView];
    
    [_mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(_mainTitleLabel.mas_bottom);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (void)setLabelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    if (labelModel && (_labelModel != labelModel)) {
        _labelModel = labelModel;
        
        if (labelModel.label.length > 0) {
            _mainTitleLabel.text = labelModel.label;
        }
        _mainTitleLabel.backgroundColor = kWhiteColor;
        [_mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:_mainTitleLabel]);
        }];
        
        mainTitleHoldView.hidden = NO;
        
        [self.mainCollectionView reloadData];
        
        switch (labelModel.style) {
            case 1:
            {
                [self.mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(labelModel.list.count < 3?Comic_MiddleCell_Height:Comic_MiddleCell_Height * 2);
                }];
            }
                break;
            case 2:
            {
                [self.mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(labelModel.list.count <= 3?Comic_NormalCell_Height:Comic_NormalCell_Height * 2);
                }];
            }
                break;
            case 3:
            {
                [self.mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(Comic_MaxCell_Height + (labelModel.list.count == 1?0:Comic_NormalCell_Height));
                }];                
            }
                break;
                
            default:
                
                break;
        }
    }
}

- (void)setShowTopMoreButton:(BOOL)showTopMoreButton
{
    _showTopMoreButton = showTopMoreButton;
    moreButton.hidden = !showTopMoreButton;
}

- (void)moreButtonClick
{
    if (self.cellSelectMoreBlock) {
        self.cellSelectMoreBlock(self.labelModel);
    }
}

@end
