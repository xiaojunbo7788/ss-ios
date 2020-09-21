//
//  WXYZ_BookDownloadMenuBarTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/4/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookDownloadMenuBarTableViewCell.h"

@implementation WXYZ_BookDownloadMenuBarTableViewCell
{
    UILabel *chapterLabel;
    UILabel *tagView;
    UILabel *downloadStateLabel;
    
    UIActivityIndicatorView *activityIndicator;
}

- (void)createSubviews
{
    [super createSubviews];
    
    chapterLabel = [[UILabel alloc] init];
    chapterLabel.textColor = kBlackColor;
    chapterLabel.textAlignment = NSTextAlignmentLeft;
    chapterLabel.font = kFont12;
    [self.contentView addSubview:chapterLabel];
    
    [chapterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(100);
    }];
    
    tagView = [[UILabel alloc] init];
    tagView.hidden = YES;
    tagView.textColor = kWhiteColor;
    tagView.textAlignment = NSTextAlignmentCenter;
    tagView.font = kFont8;
    tagView.backgroundColor = kRedColor;
    tagView.layer.cornerRadius = 4;
    tagView.clipsToBounds = YES;
    [self.contentView addSubview:tagView];
    
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(chapterLabel.mas_right);
        make.centerY.mas_equalTo(chapterLabel.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(15);
    }];
    
    downloadStateLabel = [[UILabel alloc] init];
    downloadStateLabel.hidden = YES;
    downloadStateLabel.textColor = kGrayTextLightColor;
    downloadStateLabel.textAlignment = NSTextAlignmentRight;
    downloadStateLabel.font = kFont12;
    downloadStateLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:downloadStateLabel];
    
    [downloadStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    activityIndicator.hidesWhenStopped = YES;
    [self.contentView addSubview:activityIndicator];
    //设置小菊花的frame
    [activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.width.mas_equalTo(20);
    }];
}

- (void)startDownloadLoading
{
    [activityIndicator startAnimating];
}

- (void)setOptionModel:(WXYZ_DownloadTaskModel *)optionModel
{
    _optionModel = optionModel;
    chapterLabel.text = optionModel.label?:@"";
    [chapterLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont12 labelHeight:40 labelText:optionModel.label?:@""]);
    }];
    
    if (optionModel.tag && optionModel.tag.length > 0) {
        tagView.hidden = NO;
        tagView.text = optionModel.tag;
        [tagView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont8 labelHeight:15 labelText:optionModel.tag]);
        }];
    } else {
        tagView.hidden = YES;
    }
    
    chapterLabel.textColor = kBlackColor;
    downloadStateLabel.hidden = YES;
    self.userInteractionEnabled = YES;
    
    switch ([[WXYZ_BookDownloadManager sharedManager] getDownloadMissionStateWithProduction_id:self.book_id downloadTaskModel:optionModel]) {
        case WXYZ_ProductionDownloadStateDownloading:
            chapterLabel.textColor = kGrayTextLightColor;
            downloadStateLabel.hidden = NO;
            downloadStateLabel.text = @"正在下载";
            self.userInteractionEnabled = NO;
            break;
        case WXYZ_ProductionDownloadStateDownloaded:
            chapterLabel.textColor = kGrayTextLightColor;
            downloadStateLabel.hidden = NO;
            downloadStateLabel.text = @"已下载";
            self.userInteractionEnabled = NO;
            break;
        default:
            break;
    }
}

- (void)setMissionState:(WXYZ_DownloadMissionState)missionState
{
    _missionState = missionState;
    
    [activityIndicator stopAnimating];
    
    switch (missionState) {
        case WXYZ_DownloadStateMissionStart:
            chapterLabel.textColor = kGrayTextLightColor;
            downloadStateLabel.hidden = NO;
            downloadStateLabel.text = @"正在下载";
            self.userInteractionEnabled = NO;
            break;
        case WXYZ_DownloadStateMissionFinished:
            chapterLabel.textColor = kGrayTextLightColor;
            downloadStateLabel.hidden = NO;
            downloadStateLabel.text = @"已下载";
            self.userInteractionEnabled = NO;
            break;
            
        default:
            chapterLabel.textColor = kBlackColor;
            downloadStateLabel.hidden = YES;
            self.userInteractionEnabled = YES;
            break;
    }
}

@end
