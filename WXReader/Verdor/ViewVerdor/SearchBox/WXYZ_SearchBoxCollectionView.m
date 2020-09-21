//
//  WXYZ_SearchBoxCollectionView.m
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_SearchBoxCollectionView.h"
#import "WXYZ_SearchBoxCollectionViewCell.h"

@interface WXYZ_SearchBoxCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *mainCollectionViewFlowLayout;

@property (nonatomic, strong) UICollectionView *mainCollectionView;

@end

@implementation WXYZ_SearchBoxCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    [self addSubview:self.mainCollectionView];
    
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kGrayLineColor;
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.bottom.equalTo(self.mainCollectionView);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(kCellLineHeight);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.searchModel.searchList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_SearchOptionListModel *t_list = [self.searchModel.searchList objectOrNilAtIndex:indexPath.row];
    WXYZ_SearchBoxCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WXYZ_SearchBoxCollectionViewCell" forIndexPath:indexPath];
    cell.optionModel = t_list;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_SearchOptionListModel *t_list = [self.searchModel.searchList objectOrNilAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(selectSearchBoxAtIndex:selectField:selectValue:)]) {
        [self.delegate selectSearchBoxAtIndex:indexPath selectField:self.searchModel.field selectValue:t_list.value];
    }
}

- (void)setSearchModel:(WXYZ_SearchBoxModel *)searchModel
{
#if !WX_Free_Mode
    
    NSMutableArray *t_array = [searchModel.searchList mutableCopy];
    for (WXYZ_SearchOptionListModel *t_model in t_array) {
        if ([t_model.display isEqualToString:@"免费"]) {
            [t_array removeObject:t_model];
            break;
        }
    }
    searchModel.searchList = [t_array copy];
#endif
    
#if !WX_Super_Member_Mode
    
    NSMutableArray *t_array = [searchModel.searchList mutableCopy];
    for (WXYZ_SearchOptionListModel *t_model in t_array) {
        if ([t_model.display isEqualToString:@"会员"]) {
            [t_array removeObject:t_model];
            break;
        }
    }
    searchModel.searchList = [t_array copy];
#endif
    
    _searchModel = searchModel;
    
    [self.mainCollectionView reloadData];
}

- (UICollectionView *)mainCollectionView
{
    if (!_mainCollectionView) {
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.mainCollectionViewFlowLayout];
        _mainCollectionView.userInteractionEnabled = YES;
        _mainCollectionView.backgroundColor = [UIColor clearColor];
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        _mainCollectionView.alwaysBounceHorizontal = YES;
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        [_mainCollectionView registerClass:[WXYZ_SearchBoxCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_SearchBoxCollectionViewCell"];
        if (@available(iOS 11.0, *)) {
            _mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
        }
    }
    return _mainCollectionView;
}

- (UICollectionViewFlowLayout *)mainCollectionViewFlowLayout
{
    if (!_mainCollectionViewFlowLayout) {
        _mainCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _mainCollectionViewFlowLayout.estimatedItemSize = CGSizeMake(30, 30);
        _mainCollectionViewFlowLayout.minimumLineSpacing = kQuarterMargin;
        _mainCollectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, kQuarterMargin, 0, kQuarterMargin);
    }
    return _mainCollectionViewFlowLayout;
}

@end
