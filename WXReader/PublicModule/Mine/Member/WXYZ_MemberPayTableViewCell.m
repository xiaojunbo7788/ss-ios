//
//  WXYZ_MemberPayTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/11/12.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_MemberPayTableViewCell.h"
#import "WXYZ_MemberPayCellCollectionViewCell.h"
#import "WXYZ_ShadowView.h"

@implementation WXYZ_MemberPayTableViewCell
{
    UICollectionView *mainCollectionView;
    
    NSInteger selectIndex;
}

- (void)createSubviews
{
    [super createSubviews];
    
    selectIndex = 0;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = kMargin;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 5 * kMargin) / 3 , (SCREEN_WIDTH - 5 * kMargin) / 3 * 1.1);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, kHalfMargin, 0, kHalfMargin);
    
    mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [mainCollectionView registerClass:[WXYZ_MemberPayCellCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_MemberPayCellCollectionViewCell"];
    mainCollectionView.backgroundColor = [UIColor clearColor];
    mainCollectionView.alwaysBounceVertical = NO;
    mainCollectionView.showsVerticalScrollIndicator = NO;
    mainCollectionView.showsHorizontalScrollIndicator = NO;
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    [self.contentView addSubview:mainCollectionView];
    
    [mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo((SCREEN_WIDTH - 5 * kMargin) / 3 * 1.1 + kMargin);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (void)setGoodsList:(NSArray<WXYZ_GoodsModel *> *)goodsList
{
    _goodsList = goodsList;
    
    [mainCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.goodsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WXYZ_MemberPayCellCollectionViewCell";
    WXYZ_MemberPayCellCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.goodsModel = [self.goodsList objectOrNilAtIndex:indexPath.row];
    cell.cellSelected = selectIndex == indexPath.row;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectIndex = indexPath.row;
    [mainCollectionView reloadData];
    if (self.selectItemBlock) {
        self.selectItemBlock(indexPath.row);
    }
}

@end
