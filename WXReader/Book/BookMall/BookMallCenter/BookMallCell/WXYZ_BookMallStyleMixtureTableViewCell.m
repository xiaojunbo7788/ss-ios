//
//  WXYZ_BookMallStyleMixtureTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/5/20.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookMallStyleMixtureTableViewCell.h"
#import "WXYZ_BookMallVerticalModuleCollectionViewCell.h"
#import "WXYZ_BookMallHorizontalModuleCollectionViewCell.h"

@implementation WXYZ_BookMallStyleMixtureTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    [self.mainCollectionView registerClass:[WXYZ_BookMallVerticalModuleCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_BookMallVerticalModuleCollectionViewCell"];
    [self.mainCollectionView registerClass:[WXYZ_BookMallHorizontalModuleCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_BookMallHorizontalModuleCollectionViewCell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.labelModel.list.count <= 3) {
        return 1;
    }
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.labelModel.list.count <= 3) {
        return self.labelModel.list.count;
    }
    
    if (section == 0) {
        return 3;
    }
    return self.labelModel.list.count - 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WXYZ_BookMallVerticalModuleCollectionViewCell";
        WXYZ_BookMallVerticalModuleCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
        return cell;
    } else {
        static NSString *cellIdentifier = @"WXYZ_BookMallHorizontalModuleCollectionViewCell";
        WXYZ_BookMallHorizontalModuleCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row + 3];
        cell.hiddenEndLine = indexPath.row == self.labelModel.list.count - 3 - 1;
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake(BOOK_WIDTH, VerticalCellHeight);
    }
    return CGSizeMake(SCREEN_WIDTH - kMargin, HorizontalCellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0) {
        return UIEdgeInsetsMake(0, kHalfMargin, 0, kHalfMargin);
    }
    return UIEdgeInsetsMake(kHalfMargin, kHalfMargin, 0, kHalfMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kHalfMargin;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.section * 3 + indexPath.row];
    if (self.cellDidSelectItemBlock) {
        self.cellDidSelectItemBlock(labelListModel.production_id);
    }
}

@end
