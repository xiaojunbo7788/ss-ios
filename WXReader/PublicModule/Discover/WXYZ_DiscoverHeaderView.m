//
//  WXYZ_DiscoverHeaderView.m
//  WXReader
//
//  Created by Andrew on 2018/11/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_DiscoverHeaderView.h"
#import "YJBannerView.h"
#import "WXYZ_DiscoverHeaderCollectionViewCell.h"

@interface WXYZ_DiscoverHeaderView () <YJBannerViewDelegate, YJBannerViewDataSource>

@property (nonatomic, strong) YJBannerView *normalBannerView;

@property (nonatomic, strong) NSMutableArray *bannerImageArr;

@end

@implementation WXYZ_DiscoverHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (void)initialize
{
    _bannerImageArr = [NSMutableArray array];
}

- (void)createSubviews
{
    self.backgroundColor = kWhiteColor;
    
    //banner
    [self addSubview:self.normalBannerView];
}

//banner
- (YJBannerView *)normalBannerView{
    if (!_normalBannerView) {
        _normalBannerView = [YJBannerView bannerViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 4) dataSource:self delegate:self emptyImage:HoldImage placeholderImage:HoldImage selectorString:NSStringFromSelector(@selector(setImageWithURL:placeholder:))];
        _normalBannerView.pageControlAliment = PageControlAlimentCenter;
        _normalBannerView.repeatCount = 9999;
        _normalBannerView.autoDuration = 5.0f;
        _normalBannerView.pageControlStyle = PageControlCustom;
        _normalBannerView.pageControlDotSize = CGSizeMake(10, 5);
        _normalBannerView.customPageControlHighlightImage = [UIImage imageNamed:@"pageControlS"];
        _normalBannerView.customPageControlNormalImage = [UIImage imageNamed:@"pageControlN"];
    }
    return _normalBannerView;
}

- (NSArray *)bannerViewRegistCustomCellClass:(YJBannerView *)bannerView
{
    return @[[WXYZ_DiscoverHeaderCollectionViewCell class]];
}

/** 根据 Index 选择使用哪个 reuseIdentifier */
- (Class)bannerView:(YJBannerView *)bannerView reuseIdentifierForIndex:(NSInteger)index
{
    return [WXYZ_DiscoverHeaderCollectionViewCell class];
}

/** 自定义 View 刷新数据或者其他配置 */
- (UICollectionViewCell *)bannerView:(YJBannerView *)bannerView customCell:(UICollectionViewCell *)customCell index:(NSInteger)index
{
    WXYZ_DiscoverHeaderCollectionViewCell *cell = (WXYZ_DiscoverHeaderCollectionViewCell *)customCell;
    cell.imageURL = [self.bannerImageArr objectOrNilAtIndex:index];
    return cell;
}

// 将网络图片或者本地图片 或者混合数组
- (NSArray *)bannerViewImages:(YJBannerView *)bannerView
{
    return _bannerImageArr;
}

// 代理方法 点击了哪个bannerView 的 第几个元素
- (void)bannerView:(YJBannerView *)bannerView didSelectItemAtIndex:(NSInteger)index
{
    if (self.bannerrImageClickBlock) {
        self.bannerrImageClickBlock([self.banner objectOrNilAtIndex:index]);
    }
}

- (void)setBanner:(NSArray<WXYZ_BannerModel *> *)banner
{
    _banner = banner;
    
    [_bannerImageArr removeAllObjects];
    
    for (WXYZ_BannerModel *t_model in banner) {
        [_bannerImageArr addObject:t_model.image];
    }
    
    [_normalBannerView reloadData];
}

@end
