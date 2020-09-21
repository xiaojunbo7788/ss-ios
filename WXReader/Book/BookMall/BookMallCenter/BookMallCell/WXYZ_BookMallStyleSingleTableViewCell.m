//
//  WXYZ_BookMallStyleSingleTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/5/20.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookMallStyleSingleTableViewCell.h"
#import "WXYZ_BookMallVerticalModuleCollectionViewCell.h"

@implementation WXYZ_BookMallStyleSingleTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    [self.mainCollectionView registerClass:[WXYZ_BookMallVerticalModuleCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_BookMallVerticalModuleCollectionViewCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!self.labelModel.list) {
        return 3;
    }
    return self.labelModel.list.count <=3?self.labelModel.list.count:3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WXYZ_BookMallVerticalModuleCollectionViewCell";
    WXYZ_BookMallVerticalModuleCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ProductionModel *labelListModel = [self.labelModel.list objectOrNilAtIndex:indexPath.row];
    
    if (self.cellDidSelectItemBlock) {
        self.cellDidSelectItemBlock(labelListModel.production_id);
    }
}

@end
