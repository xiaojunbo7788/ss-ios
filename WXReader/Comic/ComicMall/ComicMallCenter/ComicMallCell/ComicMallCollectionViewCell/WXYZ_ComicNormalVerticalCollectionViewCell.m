//
//  WXYZ_ComicNormalVerticalCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/26.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicNormalVerticalCollectionViewCell.h"

@implementation WXYZ_ComicNormalVerticalCollectionViewCell

- (void)createSubViews
{
    [super createSubViews];
    
    [self.comicCoverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(Comic_NormalVertical_Width);
        make.height.mas_equalTo(Comic_NormalVertical_Height);
    }];
}

- (void)setComicListModel:(WXYZ_ProductionModel *)comicListModel
{
    [super setComicListModel:comicListModel];
    
    if (comicListModel.vertical_cover.length > 0) {
        self.comicCoverView.coverImageURL = comicListModel.vertical_cover;
    } else if (comicListModel.horizontal_cover.length > 0) {
        self.comicCoverView.coverImageURL = comicListModel.horizontal_cover;
    }
    
    NSString *desLabelString = @"";
    for (WXYZ_TagModel *tagModel in comicListModel.tag) {
        desLabelString = [[desLabelString stringByAppendingString:tagModel.tab?:@""] stringByAppendingString:@" "];
    }
    self.comicDesLabel.text = desLabelString?:@"";
}
@end
