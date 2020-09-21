//
//  WXYZ_BookMallStyleMixtureMoreTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/6/14.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BookMallStyleMixtureMoreTableViewCell.h"
#import "WXYZ_BookMallVerticalModuleCollectionViewCell.h"
#import "WXYZ_BookMallHorizontalModuleCollectionViewCell.h"

@implementation WXYZ_BookMallStyleMixtureMoreTableViewCell

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
    if (self.labelModel.list.count <= 1) {
        return 1;
    }
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.labelModel.list.count <= 1) {
        return 1;
    }
    
    if (section == 0) {
        return 1;
    } else {
        return self.labelModel.list.count > 3?3:self.labelModel.list.count - 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"WXYZ_BookMallHorizontalModuleCollectionViewCell";
        WXYZ_BookMallHorizontalModuleCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
        cell.hiddenEndLine = YES;
        return cell;
    } else {
        static NSString *cellIdentifier = @"WXYZ_BookMallVerticalModuleCollectionViewCell";
        WXYZ_BookMallVerticalModuleCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row + 1];
        return cell;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake(SCREEN_WIDTH - kMargin, HorizontalCellHeight);
    }
    return CGSizeMake(BOOK_WIDTH, VerticalCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.section + indexPath.row];
    if (self.cellDidSelectItemBlock) {
        self.cellDidSelectItemBlock(labelListModel.production_id);
    }
}

@end
