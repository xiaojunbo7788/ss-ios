//
//  WXYZ_BookDirectoryTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/6/11.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookDirectoryTableViewCell.h"

#import "WXYZ_CatalogModel.h"
#import "WXYZ_ProductionReadRecordManager.h"

@implementation WXYZ_BookDirectoryTableViewCell
{
    UILabel *chapterNameLabel;
#if WX_Super_Member_Mode && WX_Recharge_Mode
    UIImageView *lockIcon;
#endif
}

- (void)createSubviews
{
    [super createSubviews];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
#if WX_Super_Member_Mode && WX_Recharge_Mode
        make.right.mas_equalTo(lockIcon.mas_left).with.offset(- 5);
#else
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
#endif
        make.height.mas_equalTo(self.contentView.mas_height);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLock:) name:Notification_ChangeLock object:nil];
}

- (void)changeLock:(NSNotification *)noti {
    if ([noti.object isEqualToString:self.chapterModel.chapter_id]) {
        self.chapterModel.preview = NO;
        lockIcon.hidden = YES;
    }
}

- (void)setChapterModel:(WXYZ_CatalogListModel *)chapterModel
{
    _chapterModel = chapterModel;
    chapterNameLabel.text = chapterModel.title?:@"";
        
    #if WX_Super_Member_Mode && WX_Recharge_Mode
        if (chapterModel.isPreview == 1) {
            lockIcon.hidden = NO;
        } else {
            lockIcon.hidden = YES;
        }
    #endif
        
        if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] getReadingRecordChapter_idWithProduction_id:[chapterModel.book_id integerValue]] == [chapterModel.chapter_id integerValue]) {
            chapterNameLabel.textColor = kMainColor;
        } else if ([[WXYZ_ProductionReadRecordManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] chapterHasReadedWithProduction_id:[chapterModel.book_id integerValue] chapter_id:[chapterModel.chapter_id integerValue]]) {
            chapterNameLabel.textColor = kGrayTextColor;
        } else {
            chapterNameLabel.textColor = kBlackColor;
        }
    
}

@end
