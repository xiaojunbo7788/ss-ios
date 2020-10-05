//
//  WXYZ_RechargeHeaderView.m
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_RechargeHeaderView.h"
#import "WXYZ_DiscoverHeaderCollectionViewCell.h"
@interface WXYZ_RechargeHeaderView () <YJBannerViewDelegate, YJBannerViewDataSource>
@property (nonatomic, strong) NSMutableArray *bannerImageArr;
@property (nonatomic, strong) UIView *bgView;

@end

@implementation WXYZ_RechargeHeaderView
{
    UILabel *goldRemainLabel;
    UILabel *goldUnitLabel;
    
    UILabel *subRemainLabel;
    UILabel *subUnitLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
         _bannerImageArr = [[NSMutableArray alloc] init];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    
    self.backgroundColor = [UIColor whiteColor];
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = kColorRGB(46, 46, 48);
    [self addSubview:self.bgView];
       
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo((PUB_NAVBAR_HEIGHT + 60 + 2 * kMargin));
    }];
    
    
    goldUnitLabel = [[UILabel alloc] init];
    goldUnitLabel.textAlignment = NSTextAlignmentCenter;
    goldUnitLabel.textColor = kColorRGB(231, 185, 117);
    goldUnitLabel.font = kMainFont;
    [self.bgView addSubview:goldUnitLabel];
    
    [goldUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).with.offset(kMargin);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).with.offset(- kMargin);
        make.width.mas_equalTo((SCREEN_WIDTH - 2 * kMargin) / 2);
        make.height.mas_equalTo(20);
    }];
    
    goldRemainLabel = [[UILabel alloc] init];
    goldRemainLabel.textAlignment = NSTextAlignmentCenter;
    goldRemainLabel.textColor = kColorRGB(231, 185, 117);
    goldRemainLabel.font = kBoldFont30;
    [self.bgView addSubview:goldRemainLabel];
    
    [goldRemainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(goldUnitLabel.mas_left);
        make.bottom.mas_equalTo(goldUnitLabel.mas_top).with.offset(- kHalfMargin);
        make.width.mas_equalTo(goldUnitLabel.mas_width);
        make.height.mas_equalTo(30);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kGrayViewColor;
    [self.bgView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(goldRemainLabel.mas_right);
        make.top.mas_equalTo(goldRemainLabel.mas_top);
        make.bottom.mas_equalTo(goldUnitLabel.mas_bottom);
        make.width.mas_equalTo(kCellLineHeight);
    }];
    
    subUnitLabel = [[UILabel alloc] init];
    subUnitLabel.textAlignment = NSTextAlignmentCenter;
    subUnitLabel.textColor = kWhiteColor;
    subUnitLabel.font = kMainFont;
    [self.bgView addSubview:subUnitLabel];
    
    [subUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(goldUnitLabel.mas_top);
        make.width.mas_equalTo(goldUnitLabel.mas_width);
        make.height.mas_equalTo(goldUnitLabel.mas_height);
    }];
    
    subRemainLabel = [[UILabel alloc] init];
    subRemainLabel.textAlignment = NSTextAlignmentCenter;
    subRemainLabel.textColor = kWhiteColor;
    subRemainLabel.font = kBoldFont30;
    [self.bgView addSubview:subRemainLabel];
    
    [subRemainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(subUnitLabel.mas_right);
        make.top.mas_equalTo(goldRemainLabel.mas_top);
        make.width.mas_equalTo(subUnitLabel.mas_width);
        make.height.mas_equalTo(goldRemainLabel.mas_height);
    }];
    
    //banner
    [self addSubview:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(SCREEN_WIDTH / 4);
    }];
    
}

- (void)setRechargeModel:(WXYZ_RechargeModel *)rechargeModel
{
    _rechargeModel = rechargeModel;
    
    goldUnitLabel.text = rechargeModel.goldUnit?:@"";
    subUnitLabel.text = rechargeModel.silverUnit?:@"";
    
    if (WXYZ_UserInfoManager.isLogin) {
        goldRemainLabel.text = [WXYZ_UtilsHelper formatStringWithInteger:rechargeModel.goldRemain];
        subRemainLabel.text = [WXYZ_UtilsHelper formatStringWithInteger:rechargeModel.silverRemain];
    } else {
        goldRemainLabel.text = @"--";
        subRemainLabel.text = @"--";
    }
}



- (void)setBanner:(NSArray<WXYZ_BannerModel *> *)banner
{
    if (banner) {
        _banner = banner;
        
        [_bannerImageArr removeAllObjects];
        
        if (banner.count == 0) {
//            self.bannerView.frame = CGRectMake(0, kHalfMargin, SCREEN_WIDTH, 0);
            _bannerView.hidden = true;
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, (PUB_NAVBAR_HEIGHT + 60 + 2 * kMargin));
        } else {
             _bannerView.hidden = false;
//            self.bannerView.frame = CGRectMake(0, kHalfMargin, SCREEN_WIDTH, SCREEN_WIDTH / 4);
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, (PUB_NAVBAR_HEIGHT + 60 + 2 * kMargin)+SCREEN_WIDTH / 4+20);
            for (WXYZ_BannerModel *t_model in banner) {
                [_bannerImageArr addObject:t_model.image];
            }
            
            [self.bannerView reloadData];
        }
    }
}

- (YJBannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [YJBannerView bannerViewWithFrame:CGRectMake(0, (PUB_NAVBAR_HEIGHT + 60 + 2 * kMargin), SCREEN_WIDTH, SCREEN_WIDTH / 4 + 20) dataSource:self delegate:self emptyImage:HoldImage placeholderImage:HoldImage selectorString:NSStringFromSelector(@selector(setImageWithURL:placeholder:))];
        _bannerView.pageControlAliment = PageControlAlimentCenter;
        _bannerView.hidden = true;
        _bannerView.repeatCount = 9999;
        _bannerView.autoDuration = 5.0f;
        _bannerView.pageControlStyle = PageControlCustom;
        _bannerView.pageControlDotSize = CGSizeMake(10, 5);
        _bannerView.customPageControlHighlightImage = [UIImage imageNamed:@"pageControlS"];
        _bannerView.customPageControlNormalImage = [UIImage imageNamed:@"pageControlN"];
    }
    return _bannerView;
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

@end
