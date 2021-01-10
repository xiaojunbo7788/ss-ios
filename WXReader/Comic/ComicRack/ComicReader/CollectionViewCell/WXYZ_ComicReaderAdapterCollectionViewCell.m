//
//  WXYZ_ComicReaderAdapterCollectionViewCell.m
//  WXReader
//
//  Created by geng on 2020/9/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ComicReaderAdapterCollectionViewCell.h"
#import "WXYZ_ComicReaderCollectionCell.h"

@interface WXYZ_ComicReaderAdapterCollectionViewCell () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,WXYZ_ComicReaderCollectionCellCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;


@end

@implementation WXYZ_ComicReaderAdapterCollectionViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UICollectionViewFlowLayout *normalFlowLayout = [[UICollectionViewFlowLayout alloc]init];
        normalFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        normalFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:normalFlowLayout];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.bounces = YES;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;

        UIGestureRecognizer *gesture = _collectionView.pinchGestureRecognizer;
        [_collectionView removeGestureRecognizer:gesture];

        [self.contentView addSubview:_collectionView];
        [_collectionView registerClass:[WXYZ_ComicReaderCollectionCell class] forCellWithReuseIdentifier:@"WXYZ_ComicReaderCollectionCell"];

        @weakify(self);
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(SCREEN_HEIGHT);
        }];
    }
    return self;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return  self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    WXYZ_ComicReaderCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WXYZ_ComicReaderCollectionCell" forIndexPath:indexPath];
     cell.localRow = (int)indexPath.item;
    cell.comic_id = self.comic_id;
    cell.chapter_id = self.chapter_id;
    cell.delegate = self;
    cell.chapter_update_time = self.chapter_update_time;
    cell.imageModel = [self.dataArray objectOrNilAtIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(SCREEN_WIDTH, collectionView.height-1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return  0.1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)reloadDataByArray:(NSMutableArray *)dataArray {
    self.dataArray = [dataArray mutableCopy];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
}

- (void)refreshCurrentCell:(int)row {
    
}

@end
