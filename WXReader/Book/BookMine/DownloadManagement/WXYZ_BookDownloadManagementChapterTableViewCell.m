//
//  WXYZ_BookDownloadManagementChapterTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/4/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BookDownloadManagementChapterTableViewCell.h"
#import "WXYZ_BookDownloadManager.h"

@interface WXYZ_BookDownloadManagementChapterTableViewCell ()

@property (nonatomic, weak) UIView *mainView;

@property (nonatomic, weak) UILabel *chapterLabel;

@property (nonatomic, weak) UILabel *subChapterLabel;

@end

@implementation WXYZ_BookDownloadManagementChapterTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapClick)]];
    
    UIView *mainView = [[UIView alloc] init];
    self.mainView = mainView;
    mainView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.width.equalTo(self.contentView);
    }];
    
    UILabel *chapterLabel = [[UILabel alloc] init];
    self.chapterLabel = chapterLabel;
    chapterLabel.textColor = kBlackColor;
    chapterLabel.textAlignment = NSTextAlignmentLeft;
    chapterLabel.numberOfLines = 0;
    chapterLabel.font = kMainFont;
    [mainView addSubview:chapterLabel];
    
    [chapterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(mainView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(mainView.mas_top).with.offset(kHalfMargin);
    }];
    
    UILabel *subChapterLabel = [[UILabel alloc] init];
    self.subChapterLabel = subChapterLabel;
    subChapterLabel.textColor = kGrayTextLightColor;
    subChapterLabel.textAlignment = NSTextAlignmentLeft;
    subChapterLabel.numberOfLines = 0;
    subChapterLabel.font = kFont11;
    [mainView addSubview:subChapterLabel];
    
    [subChapterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(chapterLabel);
        make.top.mas_equalTo(chapterLabel.mas_bottom).offset(2.0f);
        make.bottom.mas_equalTo(mainView.mas_bottom).with.offset(- kHalfMargin);
    }];
    
    [mainView addSubview:self.retryButton];
    
    UILabel *stateLabel = [[UILabel alloc] init];
    stateLabel.textAlignment = NSTextAlignmentRight;
    stateLabel.textColor = kGrayTextLightColor;
    stateLabel.font = kFont11;
    stateLabel.text = @"已下载";
    [mainView addSubview:stateLabel];
    
    [stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(mainView.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(mainView.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(mainView.mas_height);
    }];
    
    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(mainView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(mainView.mas_centerY);
    }];
    
    [chapterLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.retryButton.mas_left).offset(-kHalfMargin);
    }];
}

- (void)cellTapClick {
//    if (_isEditting) {
//        !self.selecteEdittingCellBlock ?: self.selecteEdittingCellBlock(self.bookModel);
//        return;
//    }
}

- (void)retryButtonClick
{
    if (self.retryButton.titleLabel.text.length == 0) return;
//    if (_isEditting) {
//        !self.selecteEdittingCellBlock ?: self.selecteEdittingCellBlock(self.bookModel);
//        return;
//    }
    self.retryButton.enabled = NO;
    
    WS(weakSelf)
    WXYZ_BookDownloadManager *bookDownloadManager = [WXYZ_BookDownloadManager sharedManager];
    [bookDownloadManager downloadChaptersWithProductionModel:self.bookModel downloadTaskModel:self.downloadTaskModel production_id:self.bookModel.production_id start_chapter_id:[_downloadTaskModel.start_chapter_id integerValue] downloadNum:_downloadTaskModel.down_num];
    
    bookDownloadManager.downloadMissionStateChangeBlock = ^(WXYZ_DownloadMissionState state, NSInteger production_id, WXYZ_DownloadTaskModel * _Nonnull downloadTaskModel, NSArray<NSNumber *> * _Nullable chapterIDArray) {
        if (state == WXYZ_DownloadStateMissionFail) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"重试失败"];
            weakSelf.retryButton.enabled = YES;
        }
    };
}

- (void)setDownloadTaskModel:(WXYZ_DownloadTaskModel *)downloadTaskModel
{
    _downloadTaskModel = downloadTaskModel;
    
    self.chapterLabel.text = downloadTaskModel.download_title;
    
    self.subChapterLabel.text = [NSString stringWithFormat:@"%@ %@", downloadTaskModel.dateString, downloadTaskModel.file_size_title];
    
    WS(weakSelf)
    WXYZ_BookDownloadManager *bookDownloadManager = [WXYZ_BookDownloadManager sharedManager];
    bookDownloadManager.downloadMissionStateChangeBlock = ^(WXYZ_DownloadMissionState state, NSInteger production_id, WXYZ_DownloadTaskModel * _Nonnull downloadTaskModel, NSArray<NSNumber *> * _Nullable chapterIDArray) {
        switch (state) {
            case WXYZ_DownloadStateMissionFinished:
                weakSelf.retryButton.enabled = NO;
                [weakSelf.retryButton setTitle:@"已下载" forState:UIControlStateNormal];
                break;
            case WXYZ_DownloadStateMissionFail:
                [weakSelf.retryButton setTitle:@"失败重试" forState:UIControlStateNormal];
                weakSelf.retryButton.enabled = YES;
                break;
                
            default:
                break;
        }
    };
}

- (UIButton *)retryButton
{
    if (!_retryButton) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_retryButton setTitleColor:kGrayTextLightColor forState:UIControlStateNormal];
        [_retryButton.titleLabel setFont:kFont12];
        [_retryButton addTarget:self action:@selector(retryButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryButton;
}

- (void)setEditing:(BOOL)editing {
    if (editing && _isEditting == NO) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(16.0 + 17.0);
            }];
            [self.mainView.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (finished) {
                self->_isEditting = YES;
            }
        }];
        return;
    }
    
    if (!editing && _isEditting == YES) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView);
            }];
            [self.mainView.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (finished) {
                self->_isEditting = NO;
            }
        }];
        return;
    }
}

- (void)set_Editing:(BOOL)editing {
    if (editing) {
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16.0 + 17.0);
        }];
    } else {
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
        }];
    }
    [self.mainView.superview layoutIfNeeded];
    _isEditting = editing;
}

@end
