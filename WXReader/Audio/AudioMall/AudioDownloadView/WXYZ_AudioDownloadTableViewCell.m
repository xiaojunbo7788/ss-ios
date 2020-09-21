//
//  WXYZ_AudioDownloadTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioDownloadTableViewCell.h"
#import "WXYZ_AudioDownloadManager.h"

@implementation WXYZ_AudioDownloadTableViewCell
{
    UIImageView *selectImageView;
    
    UILabel *audioChapterLabel;
    
    UIImageView *fileIcon;
    UILabel *fileLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_download_unselect"]];
    [self.contentView addSubview:selectImageView];
    
    [selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(20);
    }];
    
    audioChapterLabel = [[UILabel alloc] init];
    audioChapterLabel.textAlignment = NSTextAlignmentLeft;
    audioChapterLabel.textColor = kBlackColor;
    audioChapterLabel.font = kMainFont;
    audioChapterLabel.numberOfLines = 2;
    [self.contentView addSubview:audioChapterLabel];
    
    [audioChapterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(selectImageView.mas_right).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(15);
    }];
    
    fileIcon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"audio_file_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    fileIcon.userInteractionEnabled = YES;
    fileIcon.tintColor = kGrayTextColor;
    [self.contentView addSubview:fileIcon];
    
    [fileIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(audioChapterLabel.mas_left);
        make.top.mas_equalTo(audioChapterLabel.mas_bottom).with.offset(kQuarterMargin);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(15);
    }];
    
    fileLabel = [[UILabel alloc] init];
    fileLabel.textColor = kGrayTextColor;
    fileLabel.textAlignment = NSTextAlignmentLeft;
    fileLabel.font = kFont10;
    [self.contentView addSubview:fileLabel];
    
    [fileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(fileIcon.mas_right).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(fileIcon.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(fileIcon.mas_height);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
}

- (void)setChapterModel:(WXYZ_ProductionChapterModel *)chapterModel
{
    _chapterModel = chapterModel;
    
    fileLabel.text = [WXYZ_UtilsHelper convertFileSize:chapterModel.size];
    
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:chapterModel.chapter_title?:@""];
    if (chapterModel.is_preview == 1 && [[WXYZ_AudioDownloadManager sharedManager] getChapterDownloadStateWithProduction_id:chapterModel.production_id chapter_id:chapterModel.chapter_id] != WXYZ_ProductionDownloadStateDownloaded) {
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [UIImage imageNamed:@"audio_directory_pay"];
        attch.bounds = CGRectMake(0, 0, kGeometricWidth(10, 246, 90), 10);
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
        [attri insertAttributedString:string atIndex:0];
    }
    audioChapterLabel.attributedText = attri;
}

- (void)setCellDownloadState:(WXYZ_ProductionDownloadState)cellDownloadState
{
    if (_cellDownloadState != cellDownloadState) {
        _cellDownloadState = cellDownloadState;
        
        switch (cellDownloadState) {
            case WXYZ_ProductionDownloadStateNormal:
            {
                selectImageView.image = [UIImage imageNamed:@"audio_download_unselect"];
                audioChapterLabel.textColor = kBlackColor;
                self.backgroundColor = kWhiteColor;
            }
                break;
            case WXYZ_ProductionDownloadStateDownloading:
            {
                selectImageView.image = [UIImage imageNamed:@"audio_downloading_list"];
                audioChapterLabel.textColor = kBlackColor;
                self.backgroundColor = kWhiteColor;
            }
                break;
            case WXYZ_ProductionDownloadStateDownloaded:
            {
                if (self.isCacheState) {
                    selectImageView.image = [UIImage imageNamed:@"audio_download_unselect"];
                    audioChapterLabel.textColor = kBlackColor;
                    self.backgroundColor = kWhiteColor;
                } else {
                    selectImageView.image = [UIImage imageNamed:@"audio_download_unenable"];
                    audioChapterLabel.textColor = kGrayTextColor;
                    self.backgroundColor = kGrayViewColor;
                }
            }
                break;
            case WXYZ_ProductionDownloadStateSelected:
            {
                selectImageView.image = [UIImage imageNamed:@"audio_download_select"];
                audioChapterLabel.textColor = kBlackColor;
                self.backgroundColor = kWhiteColor;
            }
                break;
            case WXYZ_ProductionDownloadStateFail:
                selectImageView.image = [UIImage imageNamed:@"audio_download_fail_list"];
                audioChapterLabel.textColor = kBlackColor;
                self.backgroundColor = kWhiteColor;
                break;
                
            default:
                break;
        }        
    }
}

@end
