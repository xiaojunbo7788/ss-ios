//
//  WXYZ_BookMallStyleDoubleTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/5/20.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookMallStyleDoubleTableViewCell.h"
#import "WXYZ_BookMallVerticalModuleCollectionViewCell.h"

@implementation WXYZ_BookMallStyleDoubleTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    [self.mainCollectionView registerClass:[WXYZ_BookMallVerticalModuleCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_BookMallVerticalModuleCollectionViewCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.labelModel.list.count <= 6?self.labelModel.list.count:6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WXYZ_BookMallVerticalModuleCollectionViewCell";
    WXYZ_BookMallVerticalModuleCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kHalfMargin;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    if (self.cellDidSelectItemBlock) {
        self.cellDidSelectItemBlock(labelListModel.production_id);
    }
}

@end
