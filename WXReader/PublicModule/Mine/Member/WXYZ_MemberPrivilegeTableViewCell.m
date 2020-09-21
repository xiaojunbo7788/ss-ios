//
//  WXYZ_MemberPrivilegeTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_MemberPrivilegeTableViewCell.h"
#import "WXYZ_MemberPrivilegeCellCollectionViewCell.h"

@implementation WXYZ_MemberPrivilegeTableViewCell
{
    UICollectionView *mainCollectionView;
}

- (void)createSubviews
{
    [super createSubviews];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH / 4 , SCREEN_WIDTH / 4);
    
    mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [mainCollectionView registerClass:[WXYZ_MemberPrivilegeCellCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_MemberPrivilegeCellCollectionViewCell"];
    mainCollectionView.backgroundColor = [UIColor clearColor];
    mainCollectionView.alwaysBounceVertical = NO;
    mainCollectionView.showsVerticalScrollIndicator = NO;
    mainCollectionView.showsHorizontalScrollIndicator = NO;
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    [self.contentView addSubview:mainCollectionView];
    
    [mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(SCREEN_WIDTH / 4);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (void)setPrivilege:(NSArray<WXYZ_PrivilegeModel *> *)privilege
{
    _privilege = privilege;
    
    if (privilege.count > 0) {
        [mainCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo((SCREEN_WIDTH / 4) * (privilege.count % 4 == 0?(privilege.count / 4):((privilege.count / 4) + 1)));
        }];
        
        [mainCollectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.privilege.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WXYZ_MemberPrivilegeCellCollectionViewCell";
    WXYZ_MemberPrivilegeCellCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.privilegeModel = [self.privilege objectOrNilAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    WXYZ_ProductionModel *labelListModel = [self.model.list objectOrNilAtIndex:indexPath.row];
    
    //    if (self.cellDidSelectItemBlock) {
    //        self.cellDidSelectItemBlock(labelListModel.production_id);
    //    }
}


@end
