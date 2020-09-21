//
//  WXYZ_ComicNormalStyleTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/26.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicNormalStyleTableViewCell.h"
#import "WXYZ_ComicNormalVerticalCollectionViewCell.h"

@implementation WXYZ_ComicNormalStyleTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    [self.mainCollectionView registerClass:[WXYZ_ComicNormalVerticalCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_ComicNormalVerticalCollectionViewCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.labelModel.list.count <= 6?self.labelModel.list.count:6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WXYZ_ComicNormalVerticalCollectionViewCell";
    WXYZ_ComicNormalVerticalCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.comicListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(Comic_NormalCell_Width, Comic_NormalCell_Height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *listModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    if (self.cellDidSelectItemBlock) {
        self.cellDidSelectItemBlock(listModel.production_id);
    }
}

@end
