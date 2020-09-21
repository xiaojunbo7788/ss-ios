//
//  WXYZ_ComicMiddleCrossCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/26.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMiddleCrossCollectionViewCell.h"

@implementation WXYZ_ComicMiddleCrossCollectionViewCell

- (void)createSubViews
{
    [super createSubViews];
    
    self.comicCoverView.productionCoverDirection = WXYZ_ProductionCoverDirectionHorizontal;
    
    [self.comicCoverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(Comic_MiddleCross_Width);
        make.height.mas_equalTo(Comic_MiddleCross_Height);
    }];
}

- (void)setComicListModel:(WXYZ_ProductionModel *)comicListModel
{
    [super setComicListModel:comicListModel];
    
    if (comicListModel.horizontal_cover.length > 0) {
        self.comicCoverView.coverImageURL = comicListModel.horizontal_cover;
    } else if (comicListModel.vertical_cover.length > 0) {
        self.comicCoverView.coverImageURL = comicListModel.vertical_cover;
    }
    
    self.comicDesLabel.text = comicListModel.production_descirption?:@"";
}

@end
