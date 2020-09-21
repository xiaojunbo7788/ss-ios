//
//  WXYZ_ComicDirectoryListTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/30.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDirectoryListTableViewCell.h"
#import "WXYZ_ProductionCoverView.h"

@implementation WXYZ_ComicDirectoryListTableViewCell
{
    WXYZ_ProductionCoverView *comicCoverImageView;
    
    UILabel *comicTitleLabel;
    UILabel *comicSubTitleLabel;
    
    UIView *grayMask;
    
    UIImageView *currentReadImageView;
}

- (void)createSubviews
{
    [super createSubviews];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    comicCoverImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeComic productionCoverDirection:WXYZ_ProductionCoverDirectionHorizontal];
    [self.contentView addSubview:comicCoverImageView];
    
    [comicCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin * 0.8);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.4).with.offset(- kMargin - kHalfMargin);
        make.height.mas_equalTo(kGeometricHeight(((SCREEN_WIDTH * 0.4) - kMargin - kHalfMargin), 5, 3));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin * 0.8).priorityLow();
    }];
    
    comicTitleLabel = [[UILabel alloc] init];
    comicTitleLabel.textColor = kBlackColor;
    comicTitleLabel.textAlignment = NSTextAlignmentLeft;
    comicTitleLabel.font = kMainFont;
    [self.contentView addSubview:comicTitleLabel];
    
    [comicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(comicCoverImageView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(comicCoverImageView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(30);
    }];
    
    comicSubTitleLabel = [[UILabel alloc] init];
    comicSubTitleLabel.textColor = kGrayTextColor;
    comicSubTitleLabel.textAlignment = NSTextAlignmentLeft;
    comicSubTitleLabel.font = kFont12;
    [self.contentView addSubview:comicSubTitleLabel];
    
    [comicSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(comicTitleLabel.mas_left);
        make.bottom.mas_equalTo(comicCoverImageView.mas_bottom);
        make.right.mas_equalTo(comicTitleLabel.mas_right);
        make.height.mas_equalTo(20);
    }];
    
    grayMask = [[UIView alloc] init];
    grayMask.backgroundColor = kWhiteColor;
    grayMask.alpha = 0;
    grayMask.userInteractionEnabled = YES;
    [self.contentView addSubview:grayMask];

    [grayMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    currentReadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comic_current_read"]];
    currentReadImageView.hidden = YES;
    [self.contentView addSubview:currentReadImageView];
    
    [currentReadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.width.height.mas_equalTo(20);
    }];
    
}

- (void)setChapterModel:(WXYZ_ProductionChapterModel *)chapterModel
{
    _chapterModel = chapterModel;
    
    comicCoverImageView.coverImageURL = chapterModel.cover;
    comicCoverImageView.is_locked = chapterModel.is_preview;
    
    comicTitleLabel.text = chapterModel.chapter_title?:@"";
    
    comicSubTitleLabel.text = chapterModel.subtitle?:@"";
    
    if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapter_idWithProduction_id:chapterModel.production_id] == chapterModel.chapter_id) {
        self.contentView.backgroundColor = kGrayLineColor;
        grayMask.alpha = 0.7;
        currentReadImageView.hidden = NO;
    } else if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] chapterHasReadedWithProduction_id:chapterModel.production_id chapter_id:chapterModel.chapter_id]) {
        self.contentView.backgroundColor = kGrayLineColor;
        grayMask.alpha = 0.7;
        currentReadImageView.hidden = YES;
    } else {
        self.contentView.backgroundColor = kWhiteColor;
        grayMask.alpha = 0;
        currentReadImageView.hidden = YES;
    }
}

@end
