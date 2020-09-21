//
//  WXYZ_BookDownloadManagementTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/4/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BookDownloadManagementTableViewCell.h"

@interface WXYZ_BookDownloadManagementTableViewCell ()

@property (nonatomic, weak) WXYZ_ProductionCoverView *bookImageView;

@property (nonatomic, weak) UILabel *bookTitleLabel;

@property (nonatomic, weak) UIImageView *selectedView;

@property (nonatomic, weak) UIView *mainView;

@end

@implementation WXYZ_BookDownloadManagementTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openBookClick)]];
    
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
    
    WXYZ_ProductionCoverView *bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    self.bookImageView = bookImageView;
    bookImageView.userInteractionEnabled = YES;
    [bookImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapClick:)]];
    [mainView addSubview:bookImageView];
    
    [bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(selectedView.mas_right).with.offset(kMoreHalfMargin);
        make.top.mas_equalTo(mainView.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(BOOK_WIDTH_SMALL - kMargin);
        make.height.mas_equalTo(kGeometricHeight(BOOK_WIDTH_SMALL - kMargin, 3, 4));
        make.bottom.mas_equalTo(mainView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
    UILabel *bookTitleLabel = [[UILabel alloc] init];
    self.bookTitleLabel = bookTitleLabel;
    bookTitleLabel.numberOfLines = 0;
    bookTitleLabel.backgroundColor = [UIColor clearColor];
    bookTitleLabel.font = kMainFont;
    bookTitleLabel.textColor = kBlackColor;
    bookTitleLabel.textAlignment = NSTextAlignmentLeft;
    [mainView addSubview:bookTitleLabel];
    
    [bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookImageView.mas_right).with.offset(kHalfMargin);
        make.top.height.equalTo(bookImageView);
    }];
    
    self.openBook = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openBook.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.openBook setTitle:@"打开" forState:UIControlStateNormal];
    [self.openBook setTitleColor:kMainColor forState:UIControlStateNormal];
    [self.openBook.titleLabel setFont:kMainFont];
    [self.openBook addTarget:self action:@selector(openBookClick) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:self.openBook];
    
    [self.openBook mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(mainView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(mainView.mas_centerY);
    }];
    
    [bookTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.openBook.mas_left).offset(-kQuarterMargin);
    }];
}

- (void)openBookClick
{
    if (_isEditting) {
        [self switchSelectedState:!_isSelected];
        return;
    }
    if (self.openBookBlock) {
        self.openBookBlock([WXYZ_UtilsHelper formatStringWithInteger:_productionModel.production_id]);
    }
}

- (void)cellTapClick:(UITapGestureRecognizer *)tap
{
    if (_isEditting) {
        [self switchSelectedState:!_isSelected];
        return;
    }
    !self.cellSelectBlock ?: self.cellSelectBlock(_productionModel.production_id);
}

- (void)setProductionModel:(WXYZ_ProductionModel *)productionModel
{
    _productionModel = productionModel;
    
    self.bookImageView.coverImageURL = productionModel.cover;
    
    self.bookTitleLabel.text = productionModel.name;
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
    !self.selecteEdittingCellBlock ?: self.selecteEdittingCellBlock(self.productionModel, state);
}

- (void)setEditing:(BOOL)editing {    
    if (editing && _isEditting == NO) {
        self.openBook.hidden = editing;
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
        self.openBook.hidden = editing;
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
