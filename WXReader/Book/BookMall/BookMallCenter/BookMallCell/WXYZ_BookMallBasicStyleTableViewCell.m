//
//  WXYZ_BookMallBasicStyleTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/5/21.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookMallBasicStyleTableViewCell.h"
#import "WXYZ_BookMallHorizontalModuleCollectionViewCell.h"
#import "WXYZ_BookMallVerticalModuleCollectionViewCell.h"

#import "WXYZ_CountDownView.h"

@interface WXYZ_BookMallBasicStyleTableViewCell ()

@end

@implementation WXYZ_BookMallBasicStyleTableViewCell
{
    UIImageView *mainTitleHoldView;
    
    WXYZ_CountDownView *countDown;
    WXYZ_CustomButton *moreButton;
    WXYZ_CustomButton *refreshButton;
}

- (void)createSubviews
{
    [super createSubviews];
    
    // 主标题
    self.mainTitleLabel = [[UILabel alloc] init];
    self.mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.mainTitleLabel.textColor = kBlackColor;
    self.mainTitleLabel.backgroundColor = kGrayViewColor;
    self.mainTitleLabel.font = kBoldFont16;
    [self.contentView addSubview:self.mainTitleLabel];
    
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin + kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(100);
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
        make.centerY.mas_equalTo(self.mainTitleLabel.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    refreshButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"换一换" buttonImageName:@"comic_mall_refresh" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    refreshButton.buttonTintColor = kGrayTextLightColor;
    refreshButton.graphicDistance = 5;
    refreshButton.buttonImageScale = 0.5;
    refreshButton.hidden = YES;
    [refreshButton addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:refreshButton];
    
    [refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(_mainTitleLabel.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    mainTitleHoldView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_label_hold"]];
    mainTitleHoldView.hidden = YES;
    [self.contentView addSubview:mainTitleHoldView];
    
    [mainTitleHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.centerY.mas_equalTo(_mainTitleLabel.mas_centerY);
        make.width.mas_equalTo(kHalfMargin + kQuarterMargin);
        make.height.mas_equalTo(kHalfMargin + kQuarterMargin);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(BOOK_WIDTH , VerticalCellHeight);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, kHalfMargin, 0, kHalfMargin);
    
    self.mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.mainCollectionView.scrollEnabled = NO;
    self.mainCollectionView.backgroundColor = [UIColor clearColor];
    self.mainCollectionView.alwaysBounceVertical = NO;
    self.mainCollectionView.showsVerticalScrollIndicator = NO;
    self.mainCollectionView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.contentView addSubview:self.mainCollectionView];
    
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
    
    // 倒计时
    countDown = [[WXYZ_CountDownView alloc] init];
    countDown.hidden = YES;
    [self.contentView addSubview:countDown];
    
    [countDown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainTitleLabel.mas_right).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(self.mainTitleLabel.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(20);
    }];
}

- (void)setLabelModel:(WXYZ_MallCenterLabelModel *)labelModel
{
    if (labelModel && _labelModel != labelModel) {
        _labelModel = labelModel;
        
        if (labelModel.label.length > 0) {
            self.mainTitleLabel.text = labelModel.label;
        }
        self.mainTitleLabel.backgroundColor = kWhiteColor;
        [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:self.mainTitleLabel]);
        }];
        
        if (labelModel.expire_time > 0) {
            countDown.hidden = NO;
            countDown.timeStamp = labelModel.expire_time;
        } else if (labelModel.expire_time == -1) {
            countDown.hidden = YES;
            countDown.timeStamp = 0;
        } else {
            countDown.hidden = YES;
        }
        
        mainTitleHoldView.hidden = NO;
        
        [self.mainCollectionView reloadData];
        
        switch (labelModel.style) {
            case 1: // WXYZ_BookMallStyleSingleTableViewCell
            {
                [self.mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(VerticalCellHeight + kHalfMargin);
                }];
            }
                break;
            case 2: // WXYZ_BookMallStyleDoubleTableViewCell
            {
                [self.mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.labelModel.list.count <= 3?(VerticalCellHeight + kHalfMargin):((VerticalCellHeight + kHalfMargin) * 2));
                }];
            }
                break;
            case 3: // WXYZ_BookMallStyleMixtureTableViewCell
            {
                [self.mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.labelModel.list.count <= 3?(VerticalCellHeight + kHalfMargin):VerticalCellHeight + (HorizontalCellHeight + kHalfMargin) * ((self.labelModel.list.count - 3) <= 3?(self.labelModel.list.count - 3):3));
                }];
            }
                break;
            case 4: // WXYZ_BookMallStyleMixtureMoreTableViewCell
            {
                [self.mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.labelModel.list.count <= 1?HorizontalCellHeight:VerticalCellHeight + HorizontalCellHeight + kHalfMargin);
                }];
            }
                break;
                
            default:
            {
                [self.mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(VerticalCellHeight + kHalfMargin);
                }];
            }
                break;
        }
    }
}

- (void)setShowTopMoreButton:(BOOL)showTopMoreButton
{
    _showTopMoreButton = showTopMoreButton;
    moreButton.hidden = !showTopMoreButton;
    refreshButton.hidden = showTopMoreButton;
}

- (void)setShowTopRefreshButton:(BOOL)showTopRefreshButton
{
    _showTopRefreshButton = showTopRefreshButton;
    refreshButton.hidden = !showTopRefreshButton;
    moreButton.hidden = showTopRefreshButton;
}

- (void)stopRefreshing
{
    [refreshButton stopSpin];
}

- (void)moreButtonClick
{
    if (self.cellSelectMoreBlock) {
        self.cellSelectMoreBlock(self.labelModel);
    }
}

- (void)refreshButtonClick
{
    [refreshButton startSpin];
    if (self.cellSelectRefreshBlock) {
        self.cellSelectRefreshBlock(self.labelModel, self.cellIndexPath);
    }
}

@end
