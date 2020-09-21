//
//  WXYZ_BookMallDetailHeaderViewTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/5/25.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookMallDetailHeaderViewTableViewCell.h"
#import "WXYZ_TagView.h"

#import "UIImage+Blur.h"

@interface WXYZ_BookMallDetailHeaderViewTableViewCell ()
{
    WXYZ_ProductionCoverView *bookImageView;
    UILabel *bookNameLabel;
    UILabel *authorLabel;
    UILabel *bookIntroductionLabel;
    UILabel *commontNumLabel;
    UILabel *collecitonNumLabel;
    
}
@property (nonatomic, strong) UIImageView __block *headBackImageView;

@end

@implementation WXYZ_BookMallDetailHeaderViewTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    // 背景图
    _headBackImageView = [[UIImageView alloc] init];
    _headBackImageView.backgroundColor = [UIColor whiteColor];
    _headBackImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headBackImageView.clipsToBounds = YES;
    _headBackImageView.image = HoldImage;
    [self.contentView addSubview:_headBackImageView];
    
    [_headBackImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_WIDTH / 2 + PUB_NAVBAR_OFFSET + kMargin);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- 2 * kMargin).priorityLow();
    }];
    
    // 书籍图片
    bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    bookImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:bookImageView];
    
    [bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.bottom.mas_equalTo(_headBackImageView.mas_bottom).with.offset(kMargin);
        make.width.mas_equalTo(BOOK_WIDTH);
        make.height.mas_equalTo(BOOK_HEIGHT);
    }];
    
    // 书名
    bookNameLabel = [[UILabel alloc] init];
    bookNameLabel.textAlignment = NSTextAlignmentLeft;
    bookNameLabel.textColor = [UIColor whiteColor];
    bookNameLabel.backgroundColor = [UIColor clearColor];
    bookNameLabel.font = kBoldFont16;
    [self.contentView addSubview:bookNameLabel];
    
    [bookNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookImageView.mas_right).with.offset(kMargin);
        make.top.mas_equalTo(bookImageView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(kLabelHeight);
    }];
    
    // 作者
    authorLabel = [[UILabel alloc] init];
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.textColor = [UIColor whiteColor];
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.font = kFont12;
    [self.contentView addSubview:authorLabel];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookNameLabel.mas_left);
        make.top.mas_equalTo(bookNameLabel.mas_bottom).with.offset(5);
        make.width.mas_equalTo(bookNameLabel.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(17);
    }];
    
    // 书籍标签
    bookIntroductionLabel = [[UILabel alloc] init];
    bookIntroductionLabel.backgroundColor = [UIColor clearColor];
    bookIntroductionLabel.textColor = [UIColor whiteColor];
    bookIntroductionLabel.textAlignment = NSTextAlignmentLeft;
    bookIntroductionLabel.font = kFont12;
    [self.contentView addSubview:bookIntroductionLabel];
    
    [bookIntroductionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookNameLabel.mas_left);
        make.top.mas_equalTo(authorLabel.mas_bottom).with.offset(5);
        make.width.mas_equalTo(bookNameLabel.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(authorLabel.mas_height);
    }];
    
    // 评价数
    commontNumLabel = [[UILabel alloc] init];
    commontNumLabel.backgroundColor = [UIColor clearColor];
    commontNumLabel.textColor = [UIColor whiteColor];
    commontNumLabel.textAlignment = NSTextAlignmentLeft;
    commontNumLabel.font = kFont12;
    [self.contentView addSubview:commontNumLabel];
    
    [commontNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookNameLabel.mas_left);
        make.top.mas_equalTo(bookIntroductionLabel.mas_bottom).with.offset(kQuarterMargin);
        make.width.mas_equalTo(bookNameLabel.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(authorLabel.mas_height);
    }];
    
    collecitonNumLabel = [[UILabel alloc] init];
    collecitonNumLabel.backgroundColor = [UIColor clearColor];
    collecitonNumLabel.textColor = [UIColor whiteColor];
    collecitonNumLabel.textAlignment = NSTextAlignmentLeft;
    collecitonNumLabel.font = kFont12;
    [self.contentView addSubview:collecitonNumLabel];
    
    [collecitonNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookNameLabel.mas_left);
        make.top.mas_equalTo(commontNumLabel.mas_bottom).with.offset(kQuarterMargin);
        make.width.mas_equalTo(bookNameLabel.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(authorLabel.mas_height);
    }];
}

- (void)setBookModel:(WXYZ_ProductionModel *)bookModel
{
    if (bookModel && (_bookModel != bookModel)) {
        _bookModel = bookModel;
        
        WS(weakSelf)
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:bookModel.cover?:@""]  options:YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.headBackImageView.image = [image imgWithLightAlpha:0.4 radius:3 colorSaturationFactor:1.8];
            });
        }];
        
        bookImageView.coverImageURL = bookModel.cover;
        
        bookNameLabel.text = [WXYZ_UtilsHelper formatStringWithObject:bookModel.name?:@""];
        
        authorLabel.text = [WXYZ_UtilsHelper formatStringWithObject:bookModel.author?:@""];
        
        [bookIntroductionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bookNameLabel.mas_left);
            make.top.mas_equalTo(authorLabel.mas_bottom).with.offset(5);
            make.width.mas_equalTo(bookNameLabel.mas_width);
            make.height.mas_equalTo(authorLabel.mas_height);
        }];
        
        commontNumLabel.text = [WXYZ_UtilsHelper formatStringWithObject:bookModel.hot_num?:@""];
        
        collecitonNumLabel.text = [WXYZ_UtilsHelper formatStringWithObject:bookModel.total_favors?:@""];
        
//        // 截取简介
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:bookModel.production_descirption?:@""];
//        attributedString.lineSpacing = 5;
//        attributedString.font = kFont(13);
//        attributedString.color = kBlackColor;
//        
//        NSAttributedString *separatedString = [WXYZ_ViewHelper getSubContentWithOriginalContent:attributedString labelWidth:(SCREEN_WIDTH - 2 * (kMargin + kHalfMargin)) labelMaxLine:4];
//        bookDescriptionLabel.attributedText = separatedString;
//        [bookDescriptionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo([WXYZ_ViewHelper boundsWithFont:kFont(13) attributedText:separatedString needWidth:(SCREEN_WIDTH - 2 * (kMargin + kHalfMargin)) lineSpacing:6] + kHalfMargin);
//        }];
//        
//        tagView.tagArray = bookModel.tag;
//        
//        timeLabel.text = bookModel.last_chapter_time?:@"";
//        [timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:timeLabel]);
//        }];
//        
//        catalogueDetailLabel.text = bookModel.last_chapter?:@"";
//        
//        catalogueButton.hidden = NO;
        
    }
}

@end
