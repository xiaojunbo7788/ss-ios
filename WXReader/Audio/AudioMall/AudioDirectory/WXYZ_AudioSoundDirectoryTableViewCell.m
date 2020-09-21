//
//  WXYZ_AudioSoundDirectoryTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioSoundDirectoryTableViewCell.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_AudioDownloadManager.h"

@implementation WXYZ_AudioSoundDirectoryTableViewCell
{
    UILabel *audioChapterLabel;
    
//    UIImageView *durationIcon;
//    UILabel *durationLabel;
    
    UIImageView *readTimeIcon;
    UILabel *readTimeLabel;
    
    UIImageView *updateTimeIcon;
    UILabel *updateLabel;
    
    UIButton *downloadButton;
    
//    UIActivityIndicatorView *indicatorView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    audioChapterLabel = [[UILabel alloc] init];
    audioChapterLabel.textAlignment = NSTextAlignmentLeft;
    audioChapterLabel.textColor = kBlackColor;
    audioChapterLabel.font = kMainFont;
    [self.contentView addSubview:audioChapterLabel];
    
    [audioChapterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- 2 * kHalfMargin - 40);
        make.height.mas_equalTo(kLabelHeight);
    }];
    
    downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.adjustsImageWhenHighlighted = NO;
    [downloadButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [downloadButton setImage:[UIImage imageNamed:@"audio_download"] forState:UIControlStateNormal];
    [downloadButton addTarget:self action:@selector(downloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:downloadButton];
    
    [downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.width.mas_equalTo(40);
    }];
    
//    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
//    indicatorView.hidesWhenStopped = YES;
//    [downloadButton addSubview:indicatorView];
//
//    [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(downloadButton.mas_centerX);
//        make.centerY.mas_equalTo(downloadButton.mas_centerY);
//        make.width.height.mas_equalTo(downloadButton.mas_height);
//    }];
    
//    durationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_directory_duration"]];
//    [self.contentView addSubview:durationIcon];
//
//    [durationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(audioChapterLabel.mas_left);
//        make.top.mas_equalTo(audioChapterLabel.mas_bottom).with.offset(kHalfMargin);
//        make.height.mas_equalTo(12);
//        make.width.mas_equalTo(CGFLOAT_MIN);
//        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kMargin).priorityLow();
//    }];
//
//    durationLabel = [[UILabel alloc] init];
//    durationLabel.font = kFont11;
//    durationLabel.textColor = kGrayTextColor;
//    [self.contentView addSubview:durationLabel];
//
//    [durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(durationIcon.mas_right).with.offset(kQuarterMargin);
//        make.centerY.mas_equalTo(durationIcon.mas_centerY);
//        make.height.mas_equalTo(durationIcon.mas_height);
//        make.width.mas_equalTo(CGFLOAT_MIN);
//    }];
    
    readTimeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_directory_readtime"]];
    [self.contentView addSubview:readTimeIcon];
    
    [readTimeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(audioChapterLabel.mas_left);
        make.top.mas_equalTo(audioChapterLabel.mas_bottom).with.offset(kHalfMargin);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kMargin).priorityLow();
    }];
    
    readTimeLabel = [[UILabel alloc] init];
    readTimeLabel.font = kFont11;
    readTimeLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:readTimeLabel];
    
    [readTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(readTimeIcon.mas_right).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(readTimeIcon.mas_centerY);
        make.height.mas_equalTo(readTimeIcon.mas_height);
        make.width.mas_equalTo(CGFLOAT_MIN);
    }];
    
    updateTimeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_directory_updatetime"]];
    [self.contentView addSubview:updateTimeIcon];
    
    [updateTimeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(readTimeLabel.mas_right).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(readTimeLabel.mas_centerY);
        make.height.mas_equalTo(readTimeIcon.mas_height);
        make.width.mas_equalTo(CGFLOAT_MIN);
    }];
    
    updateLabel = [[UILabel alloc] init];
    updateLabel.font = kFont11;
    updateLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:updateLabel];
    
    [updateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(updateTimeIcon.mas_right).with.offset(kQuarterMargin);
        make.right.mas_equalTo(downloadButton.mas_left);
        make.centerY.mas_equalTo(updateTimeIcon.mas_centerY);
        make.height.mas_equalTo(updateTimeIcon.mas_height);
    }];
}

- (void)setChapterListModel:(WXYZ_ProductionChapterModel *)chapterListModel
{
    if (_chapterListModel != chapterListModel) {
        
        _chapterListModel = chapterListModel;
        
        audioChapterLabel.text = chapterListModel.chapter_title?:@"";
        
//        if (chapterListModel.duration_time.length > 0) {
//            durationIcon.hidden = NO;
//            [durationIcon mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_equalTo(12);
//            }];
//
//            durationLabel.text = chapterListModel.duration_time?:@"";
//            [durationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:durationLabel]);
//            }];
//        } else {
//            durationIcon.hidden = YES;
//            [durationIcon mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_equalTo(CGFLOAT_MIN);
//            }];
//            [durationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(durationIcon.mas_right);
//                make.width.mas_equalTo(CGFLOAT_MIN);
//            }];
//        }
        
        if (chapterListModel.play_num > 0) {
            readTimeIcon.hidden = NO;
            [readTimeIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(12);
            }];
            readTimeLabel.text = chapterListModel.play_num?:@"";
            readTimeLabel.hidden = NO;
            [readTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:readTimeLabel]);
            }];
        } else {
            readTimeIcon.hidden = YES;
            [readTimeIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(audioChapterLabel.mas_left);
                make.width.mas_equalTo(CGFLOAT_MIN);
            }];
            
            readTimeLabel.hidden = YES;
            [readTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(readTimeIcon.mas_right);
                make.width.mas_equalTo(CGFLOAT_MIN);
            }];
        }
        
        if (chapterListModel.update_time.length > 0) {
            updateTimeIcon.hidden = NO;
            [updateTimeIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(12);
            }];
            updateLabel.text = chapterListModel.update_time?:@"";
            updateLabel.hidden = NO;
        } else {
            updateTimeIcon.hidden = YES;
            [updateTimeIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(CGFLOAT_MIN);
            }];
            
            updateLabel.hidden = YES;
        }
        
    }
    if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCurrentPlayingChapterWithProduction_id:chapterListModel.production_id chapter_id:chapterListModel.chapter_id] &&
        [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] isCurrentPlayingProductionWithProduction_id:chapterListModel.production_id]) {
        audioChapterLabel.textColor = kMainColor;
    } else if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeAudio] chapterHasReadedWithProduction_id:chapterListModel.production_id chapter_id:chapterListModel.chapter_id]) {
        audioChapterLabel.textColor = kGrayTextColor;
    } else {
        audioChapterLabel.textColor = kBlackColor;
    }
    
    [self changeDownloadButtonState];
}

- (void)setCellDownloadState:(WXYZ_ProductionDownloadState)cellDownloadState
{
    if (_cellDownloadState != cellDownloadState) {
        _cellDownloadState = cellDownloadState;
        
        [self changeDownloadButtonState];
    }
}

- (void)changeDownloadButtonState
{
    switch (_cellDownloadState) {
        case WXYZ_ProductionDownloadStateNormal:
        {
            if (self.chapterListModel.is_preview == 1) {
                [downloadButton setImage:[UIImage imageNamed:@"audio_download_vip"] forState:UIControlStateNormal];
            } else {
                [downloadButton setImage:[UIImage imageNamed:@"audio_download"] forState:UIControlStateNormal];
            }
        }
            break;
        case WXYZ_ProductionDownloadStateDownloading:
        {
            [downloadButton setImage:[UIImage imageNamed:@"audio_downloading"] forState:UIControlStateNormal];
        }
            break;
        case WXYZ_ProductionDownloadStateDownloaded:
        {
            [downloadButton setImage:[UIImage imageNamed:@"audio_downloaded"] forState:UIControlStateNormal];
        }
            break;
        case WXYZ_ProductionDownloadStateFail:
        {
            [downloadButton setImage:[UIImage imageNamed:@"audio_download_fail"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

- (void)downloadButtonClick
{
    if (([[WXYZ_AudioDownloadManager sharedManager] getChapterDownloadStateWithProduction_id:self.chapterListModel.production_id chapter_id:self.chapterListModel.chapter_id] == WXYZ_ProductionDownloadStateDownloading) || ([[WXYZ_AudioDownloadManager sharedManager] getChapterDownloadStateWithProduction_id:self.chapterListModel.production_id chapter_id:self.chapterListModel.chapter_id] == WXYZ_ProductionDownloadStateDownloaded)) {
        return;
    }
    
    if (self.downloadChapterBlock) {
        self.downloadChapterBlock(self.chapterListModel.production_id, self.chapterListModel.chapter_id, self.cellIndexPath);
    }
}

@end
