//
//  WXYZ_ComicMaxStyleTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/5/26.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_ComicMaxStyleTableViewCell.h"
#import "WXYZ_ComicMaxCrossCollectionViewCell.h"
#import "WXYZ_ComicNormalVerticalCollectionViewCell.h"

@implementation WXYZ_ComicMaxStyleTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    [self.mainCollectionView registerClass:[WXYZ_ComicMaxCrossCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_ComicMaxCrossCollectionViewCell"];
    
    [self.mainCollectionView registerClass:[WXYZ_ComicNormalVerticalCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_ComicNormalVerticalCollectionViewCell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.labelModel.list.count == 0) {
        return 0;
    }
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return self.labelModel.list.count <= 3?self.labelModel.list.count:3;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WXYZ_ComicMaxCrossCollectionViewCell";
        WXYZ_ComicMaxCrossCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.comicListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
        return cell;
    } else {
        static NSString *cellIdentifier = @"WXYZ_ComicNormalVerticalCollectionViewCell";
        WXYZ_ComicNormalVerticalCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.comicListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row + 1];
        return cell;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake(Comic_MaxCell_Width, Comic_MaxCell_Height);
    }
    return CGSizeMake(Comic_NormalCell_Width, Comic_NormalCell_Height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *listModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    if (indexPath.section != 0) {
        listModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row + 1];
    }
    
    if (self.cellDidSelectItemBlock) {
        self.cellDidSelectItemBlock(listModel.production_id);
    }
}

@end
