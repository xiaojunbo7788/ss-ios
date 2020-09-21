//
//  WXYZ_BookMallVerticalModuleCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/5/21.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookMallVerticalModuleCollectionViewCell.h"

@implementation WXYZ_BookMallVerticalModuleCollectionViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    [self.productionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(BOOK_WIDTH);
        make.height.mas_equalTo(BOOK_HEIGHT);
    }];
    
    [self.bookTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.productionImageView.mas_left);
        make.top.mas_equalTo(self.productionImageView.mas_bottom).with.offset(kQuarterMargin);
        make.width.mas_equalTo(self.productionImageView.mas_width);
        make.height.mas_equalTo(BOOK_CELL_TITLE_HEIGHT / 2);
    }];

    self.bookSubTitleLabel.hidden = NO;    
}

- (void)setLabelListModel:(WXYZ_ProductionModel *)labelListModel
{
    [super setLabelListModel:labelListModel];

    NSString *desLabelString = @"";
    for (WXYZ_TagModel *tagModel in labelListModel.tag) {
        if (tagModel.tab.length > 0) {
            desLabelString = [[desLabelString stringByAppendingString:tagModel.tab?:@""] stringByAppendingString:@" "];            
        }
    }
    
    if (desLabelString.length == 0) {
        desLabelString = labelListModel.production_descirption;
    }
    self.bookSubTitleLabel.text = desLabelString;
}

@end
