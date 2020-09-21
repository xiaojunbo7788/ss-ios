//
//  WXYZ_ComicReaderBottomTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/4.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderBottomTableViewCell.h"
#import "WXYZ_ComicMenuBottomBar.h"

@implementation WXYZ_ComicReaderBottomTableViewCell
{
    WXYZ_CustomButton *previousButton;
    WXYZ_CustomButton *nextButton;
}

- (void)createSubviews
{
    [super createSubviews];
    
    previousButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"上一篇" buttonImageName:@"public_back" buttonIndicator:WXYZ_CustomButtonIndicatorTitleRight];
    previousButton.tag = 0;
    previousButton.buttonImageScale = 0.2;
    [previousButton addTarget:self action:@selector(changeChapter:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:previousButton];
    
    [previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5).with.offset(- kMargin);
        make.height.mas_equalTo(60);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- (PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height)).priorityLow();
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kGrayLineColor;
    [self.contentView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(previousButton.mas_right);
        make.height.mas_equalTo(previousButton.mas_height).with.multipliedBy(0.8);
        make.width.mas_equalTo(kCellLineHeight);
        make.centerY.mas_equalTo(previousButton.mas_centerY);
    }];
    
    nextButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"下一篇" buttonImageName:@"public_back" buttonIndicator:WXYZ_CustomButtonIndicatorTitleLeft];
    nextButton.transformImageView = YES;
    nextButton.tag = 1;
    nextButton.buttonImageScale = 0.2;
    [nextButton addTarget:self action:@selector(changeChapter:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:nextButton];
    
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(previousButton.mas_width);
        make.height.mas_equalTo(previousButton.mas_height);
    }];
    
}

- (void)setComicChapterModel:(WXYZ_ProductionChapterModel *)comicChapterModel
{
    _comicChapterModel = comicChapterModel;
    
    if (comicChapterModel.last_chapter > 0) {
        previousButton.buttonTintColor = kBlackColor;
    } else {
        previousButton.buttonTintColor = kGrayTextLightColor;
    }
    
    if (comicChapterModel.next_chapter > 0) {
        nextButton.buttonTintColor = kBlackColor;
    } else {
        nextButton.buttonTintColor = kGrayTextLightColor;
    }
}

- (void)changeChapter:(UIButton *)sender
{
    if (sender.tag == 0) { // 上一篇
        if (self.comicChapterModel.last_chapter > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Switch_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:self.comicChapterModel.last_chapter]];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"已是第一篇"];
        }
    } else { // 下一篇
        if (self.comicChapterModel.next_chapter > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Switch_Chapter object:[WXYZ_UtilsHelper formatStringWithInteger:self.comicChapterModel.next_chapter]];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"已是最后一篇"];
        }
    }
}

@end
