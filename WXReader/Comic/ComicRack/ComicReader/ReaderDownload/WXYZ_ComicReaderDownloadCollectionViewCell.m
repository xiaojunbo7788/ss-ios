//
//  WXYZ_ComicReaderDownloadCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/8.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderDownloadCollectionViewCell.h"
#import "WXYZ_ComicDownloadManager.h"

@implementation WXYZ_ComicReaderDownloadCollectionViewCell
{
    UILabel *chapterNumLabel;
    UIImageView *lockImageView;
    UILabel *cellStateLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    chapterNumLabel = [[UILabel alloc] init];
    chapterNumLabel.backgroundColor = kWhiteColor;
    chapterNumLabel.textColor = kBlackColor;
    chapterNumLabel.textAlignment = NSTextAlignmentCenter;
    chapterNumLabel.font = kMainFont;
    chapterNumLabel.layer.cornerRadius = 8;
    chapterNumLabel.clipsToBounds = YES;
    [self addSubview:chapterNumLabel];
    
    [chapterNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    lockImageView = [[UIImageView alloc] init];
    lockImageView.image = [[UIImage imageNamed:@"comic_lock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    lockImageView.tintColor = kMainColor;
    lockImageView.hidden = YES;
    [chapterNumLabel addSubview:lockImageView];
    
    [lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kQuarterMargin);
        make.top.mas_equalTo(kQuarterMargin);
        make.width.height.mas_equalTo(self.mas_height).with.multipliedBy(0.3);
    }];
    
    cellStateLabel = [[UILabel alloc] init];
    cellStateLabel.backgroundColor = [UIColor clearColor];
    cellStateLabel.textColor = kWhiteColor;
    cellStateLabel.textAlignment = NSTextAlignmentCenter;
    cellStateLabel.font = kFont6;
    cellStateLabel.layer.cornerRadius = (self.height * 0.2) / 2;
    cellStateLabel.clipsToBounds = YES;
    [chapterNumLabel addSubview:cellStateLabel];
    
    [cellStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(chapterNumLabel.mas_right).with.offset(- 2);
        make.bottom.mas_equalTo(chapterNumLabel.mas_bottom).with.offset(- 2);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(self.mas_height).with.multipliedBy(0.2);
    }];
    
}

- (void)setChapterModel:(WXYZ_ProductionChapterModel *)chapterModel
{
    _chapterModel = chapterModel;
    
    chapterNumLabel.text = chapterModel.display_label?:@"";
    
    if (chapterModel.can_read) {
        lockImageView.hidden = YES;
    } else {
        lockImageView.hidden = NO;
    }
    
    chapterNumLabel.text = chapterModel.display_label?:@"";
}

- (void)setCellDownloadState:(WXYZ_ProductionDownloadState)cellDownloadState
{
    _cellDownloadState = cellDownloadState;
    
    lockImageView.hidden = self.chapterModel.can_read;
    
    switch (cellDownloadState) {
        case WXYZ_ProductionDownloadStateNormal:
        {
            cellStateLabel.backgroundColor = [UIColor clearColor];
            cellStateLabel.hidden = YES;
            cellStateLabel.text = @"";
            
            lockImageView.tintColor = kMainColor;
            
            chapterNumLabel.backgroundColor = kWhiteColor;
            chapterNumLabel.textColor = kBlackColor;
        }
            break;
        case WXYZ_ProductionDownloadStateDownloading:
        {
            cellStateLabel.backgroundColor = kColorRGBA(28, 220, 142, 1);
            cellStateLabel.hidden = NO;
            cellStateLabel.text = @"下载中";
            
            lockImageView.tintColor = kMainColor;
            lockImageView.hidden = YES;
            
            chapterNumLabel.backgroundColor = kGrayDeepViewColor;
            chapterNumLabel.textColor = kGrayTextColor;
        }
            break;
        case WXYZ_ProductionDownloadStateDownloaded:
        {
            cellStateLabel.backgroundColor = kColorRGBA(28, 220, 142, 0.5);
            cellStateLabel.hidden = NO;
            cellStateLabel.text = @"本地";
            
            lockImageView.tintColor = kMainColor;
            lockImageView.hidden = YES;
            
            chapterNumLabel.backgroundColor = kGrayDeepViewColor;
            chapterNumLabel.textColor = kGrayTextColor;
        }
            break;
        case WXYZ_ProductionDownloadStateFail:
        {
            cellStateLabel.backgroundColor = kRedColor;
            cellStateLabel.hidden = NO;
            cellStateLabel.text = @"失败";
            
            lockImageView.tintColor = kMainColor;
            
            chapterNumLabel.backgroundColor = kWhiteColor;
            chapterNumLabel.textColor = kBlackColor;
        }
            break;
        case WXYZ_ProductionDownloadStateSelected:
        {
            cellStateLabel.backgroundColor = [UIColor clearColor];
            cellStateLabel.hidden = YES;
            cellStateLabel.text = @"";
            
            lockImageView.tintColor = kWhiteColor;
            
            chapterNumLabel.backgroundColor = kMainColor;
            chapterNumLabel.textColor = kWhiteColor;
        }
            break;
            
        default:
            break;
    }
    
    [cellStateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont6 labelHeight:(self.height * 0.2) labelText:cellStateLabel.text]);
    }];
}

@end
