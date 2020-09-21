//
//  WXYZ_AudioPlayPageMenuDirectoryTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/3/19.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AudioPlayPageMenuDirectoryTableViewCell.h"
#import "WXYZ_ProductionReadRecordManager.h"

@implementation WXYZ_AudioPlayPageMenuDirectoryTableViewCell
{
    UIImageView *leftIcon;
    
    UILabel *chapterNameLabel;
#if WX_Super_Member_Mode && WX_Recharge_Mode
    UIImageView *lockIcon;
#endif
}

- (void)createSubviews
{
    [super createSubviews];

    leftIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_directory_list"]];
    leftIcon.userInteractionEnabled = YES;
    leftIcon.hidden = YES;
    [self.contentView addSubview:leftIcon];
    
    [leftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(CGFLOAT_MIN);
        make.height.mas_equalTo(kGeometricHeight(kLabelHeight / 2, 50, 32));
    }];
    
#if WX_Super_Member_Mode && WX_Recharge_Mode
    lockIcon = [[UIImageView alloc] init];
    lockIcon.image = [[UIImage imageNamed:@"book_directory_lock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    lockIcon.tintColor = kColorRGB(139, 140, 146);
    lockIcon.hidden = YES;
    [self.contentView addSubview:lockIcon];
    
    [lockIcon mas_makeConstraints:^(MASConstraintMaker *make) {
       make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
       make.centerY.mas_equalTo(self.contentView.mas_centerY);
       make.height.width.mas_equalTo(15);
    }];
#endif
    
    // 章节名称
    chapterNameLabel = [[UILabel alloc] init];
    chapterNameLabel.textColor = kBlackColor;
    chapterNameLabel.font = kMainFont;
    chapterNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:chapterNameLabel];
    
    [chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftIcon.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
#if WX_Super_Member_Mode && WX_Recharge_Mode
        make.right.mas_equalTo(lockIcon.mas_left).with.offset(- 5);
#else
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
#endif
        make.height.mas_equalTo(self.contentView.mas_height);
    }];
}

- (void)setChapterListModel:(WXYZ_ProductionChapterModel *)chapterListModel
{
    _chapterListModel = chapterListModel;
    
    chapterNameLabel.text = chapterListModel.chapter_title?:@"";
    
#if WX_Super_Member_Mode && WX_Recharge_Mode
    if (chapterListModel.is_preview == 1) {
        lockIcon.hidden = NO;
    } else {
        lockIcon.hidden = YES;
    }
#endif
    
    if (chapterListModel.chapter_id == [[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:self.productionType] getReadingRecordChapter_idWithProduction_id:chapterListModel.production_id]) {
        chapterNameLabel.textColor = kMainColor;
        leftIcon.hidden = NO;
        [leftIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kLabelHeight / 2);
        }];
        [chapterNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(leftIcon.mas_right).with.offset(kHalfMargin);
                make.top.mas_equalTo(self.contentView.mas_top);
        #if WX_Super_Member_Mode && WX_Recharge_Mode
                make.right.mas_equalTo(lockIcon.mas_left).with.offset(- 5);
        #else
                make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        #endif
                make.height.mas_equalTo(self.contentView.mas_height);
            }];
    } else if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:self.productionType] chapterHasReadedWithProduction_id:chapterListModel.production_id chapter_id:chapterListModel.chapter_id]) {
        chapterNameLabel.textColor = kGrayTextColor;
        leftIcon.hidden = YES;
        [leftIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(CGFLOAT_MIN);
        }];
        [chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.mas_left).with.offset(kMargin);
                make.top.mas_equalTo(self.contentView.mas_top);
        #if WX_Super_Member_Mode && WX_Recharge_Mode
                make.right.mas_equalTo(lockIcon.mas_left).with.offset(- 5);
        #else
                make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        #endif
                make.height.mas_equalTo(self.contentView.mas_height);
            }];
    } else {
        chapterNameLabel.textColor = kBlackColor;
        leftIcon.hidden = YES;
        [leftIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(CGFLOAT_MIN);
        }];
        [chapterNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.mas_left).with.offset(kMargin);
                make.top.mas_equalTo(self.contentView.mas_top);
        #if WX_Super_Member_Mode && WX_Recharge_Mode
                make.right.mas_equalTo(lockIcon.mas_left).with.offset(- 5);
        #else
                make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        #endif
                make.height.mas_equalTo(self.contentView.mas_height);
            }];
    }
}

@end
