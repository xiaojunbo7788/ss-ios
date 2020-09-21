//
//  WXYZ_ComicMiddleSytleTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/26.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMiddleSytleTableViewCell.h"
#import "WXYZ_ComicMiddleCrossCollectionViewCell.h"

@implementation WXYZ_ComicMiddleSytleTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    [self.mainCollectionView registerClass:[WXYZ_ComicMiddleCrossCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_ComicMiddleCrossCollectionViewCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.labelModel.list.count <= 4?self.labelModel.list.count:4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WXYZ_ComicMiddleCrossCollectionViewCell";
    WXYZ_ComicMiddleCrossCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.comicListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(Comic_MiddleCell_Width, Comic_MiddleCell_Height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *listModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    if (self.cellDidSelectItemBlock) {
        self.cellDidSelectItemBlock(listModel.production_id);
    }
}

@end
