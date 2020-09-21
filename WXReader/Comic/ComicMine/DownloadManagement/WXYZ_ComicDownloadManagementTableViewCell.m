//
//  WXYZ_ComicDownloadManagementTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/10.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicDownloadManagementTableViewCell.h"
#import "WXYZ_ComicDownloadManager.h"
#import "WXYZ_ProductionReadRecordManager.h"

@interface WXYZ_ComicDownloadManagementTableViewCell ()

@property (nonatomic, weak) UIView *mainView;

@property (nonatomic, weak) WXYZ_ProductionCoverView *coverImageView;

@property (nonatomic, weak) UILabel *titleNameLabel;

@property (nonatomic, weak) UILabel *subTitleLabel;

@property (nonatomic, weak) UIButton *readButton;

@property (nonatomic, weak) UIImageView *selectedView;

@end

@implementation WXYZ_ComicDownloadManagementTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapClick:)]];
    
    UIView *mainView = [[UIView alloc] init];
    self.mainView = mainView;
    mainView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(-16.0f);
        make.width.equalTo(self.contentView).offset(16.0f);
        make.height.equalTo(self.contentView);
    }];
    
    UIImageView *selectedView = [[UIImageView alloc] init];
    self.selectedView = selectedView;
    selectedView.image = [YYImage imageNamed:@"audio_download_unselect"];
    [mainView addSubview:selectedView];
    [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16.0f);
        make.left.equalTo(mainView);
        make.centerY.equalTo(mainView);
    }];
    
    WXYZ_ProductionCoverView *coverImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeComic productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    self.coverImageView = coverImageView;
    coverImageView.tag = 200;
    [coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapClick:)]];
    [mainView addSubview:coverImageView];
    
    [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(selectedView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(mainView.mas_top).with.offset(kQuarterMargin);
        make.width.mas_equalTo(BOOK_WIDTH_SMALL - kMargin);
        make.height.mas_equalTo(kGeometricHeight(BOOK_WIDTH_SMALL - kMargin, 3, 4));
        make.bottom.mas_equalTo(mainView.mas_bottom).with.offset(- kQuarterMargin).priorityLow();
    }];
    
    UILabel *titleNameLabel = [[UILabel alloc] init];
    self.titleNameLabel = titleNameLabel;
    titleNameLabel.textColor = kBlackColor;
    titleNameLabel.textAlignment = NSTextAlignmentLeft;
    titleNameLabel.font = kBoldFont14;
    titleNameLabel.numberOfLines = 0;
    [mainView addSubview:titleNameLabel];
    
    [titleNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(coverImageView.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(coverImageView.mas_top);
        make.right.mas_equalTo(mainView.mas_right).offset(-kQuarterMargin);
    }];
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel = subTitleLabel;
    subTitleLabel.textColor = kGrayTextColor;
    subTitleLabel.textAlignment = NSTextAlignmentLeft;
    subTitleLabel.font = kFont12;
    subTitleLabel.numberOfLines = 1;
    [mainView addSubview:subTitleLabel];
    
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(titleNameLabel);
        make.bottom.mas_equalTo(coverImageView.mas_bottom);
    }];
    
    UIButton *readButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.readButton = readButton;
    readButton.backgroundColor = kMainColor;
    readButton.layer.cornerRadius = 12;
    [readButton setTitle:@"开始阅读" forState:UIControlStateNormal];
    [readButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [readButton.titleLabel setFont:kFont12];
    [readButton addTarget:self action:@selector(readButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:readButton];
    
    [readButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(mainView.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(mainView.mas_centerY);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(24);
    }];
    
    [titleNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.readButton.mas_top).offset(-kQuarterMargin);
    }];
    
    [subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.readButton.mas_bottom).offset(kQuarterMargin);
    }];
}

- (void)setComicModel:(WXYZ_ProductionModel *)comicModel
{
    _comicModel = comicModel;
    
    if (comicModel.vertical_cover.length > 0) {
        self.coverImageView.coverImageURL = comicModel.vertical_cover;
    } else if (comicModel.horizontal_cover.length > 0) {
        self.coverImageView.coverImageURL = comicModel.horizontal_cover;
    } else {
        self.coverImageView.coverImageURL = comicModel.cover;
    }
    
    
    self.titleNameLabel.text = comicModel.name?:@"";
    
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@话/%@话", [WXYZ_UtilsHelper formatStringWithInteger:[[WXYZ_ComicDownloadManager sharedManager] getDownloadChapterCountWithProduction_id:comicModel.production_id]], [WXYZ_UtilsHelper formatStringWithInteger:comicModel.total_chapters]];
    
    if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeComic] getReadingRecordChapterTitleWithProduction_id:comicModel.production_id].length > 0) {
        [self.readButton setTitle:@"继续阅读" forState:UIControlStateNormal];
    } else {
        [self.readButton setTitle:@"开始阅读" forState:UIControlStateNormal];
    }
}

- (void)cellTapClick:(UITapGestureRecognizer *)tap
{
    if (_isEditting) {
        [self switchSelectedState:!_isSelected];
        return;
    }
    if (tap.view.tag == 200) {
        if (self.imageViewSelectBlock) {
            self.imageViewSelectBlock(_comicModel.production_id);
        }
    } else {
        if (self.cellSelectBlock) {
            self.cellSelectBlock(_comicModel, _comicModel.name);
        }        
    }
}

- (void)readButtonClick
{
    if (self.buttonSelectBlock) {
        self.buttonSelectBlock(_comicModel);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)switchSelectedState:(BOOL)state {
    UIImage *image = nil;
    if (state) {
        image = [YYImage imageNamed:@"audio_download_select"];
    } else {
        image = [YYImage imageNamed:@"audio_download_unselect"];
    }
    _isSelected = state;
    self.selectedView.image = image;
    !self.selecteEdittingCellBlock ?: self.selecteEdittingCellBlock(self.comicModel, state);
}

- (void)setEditing:(BOOL)editing {
    if (editing && _isEditting == NO) {
        self.readButton.hidden = editing;
        [UIView animateWithDuration:0.2 animations:^{
            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(17.0f);
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
        self.readButton.hidden = editing;
        [UIView animateWithDuration:0.2 animations:^{
            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(-16.0f);
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

- (void)set_Editting:(BOOL)editting {
    if (editting) {
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(17.0f);
        }];
    } else {
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(-16.0f);
        }];
    }
    [self.mainView.superview layoutIfNeeded];
    _isEditting = editting;
}

@end
