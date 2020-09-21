//
//  WXYZ_MallCenterHeaderView.m
//  WXReader
//
//  Created by Andrew on 2019/5/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_MallCenterHeaderView.h"
#import "YJMallCollectionViewCell.h"
#import "YJBannerView.h"

#import "WXYZ_UserCenterModel.h"

@interface WXYZ_MallCenterHeaderView () <YJBannerViewDelegate, YJBannerViewDataSource>

@property (nonatomic, strong) YJBannerView *bannerView;

@property (nonatomic, strong) UIView *menuBarView;

@end

@implementation WXYZ_MallCenterHeaderView

- (instancetype)init
{
    if (self = [super init]) {
        
        CGFloat headerHeight = SCREEN_WIDTH - kHalfMargin;
        if (is_iPhone6P) {
            headerHeight = SCREEN_WIDTH - kMargin - kQuarterMargin;
        } else if (is_iPhoneX) {
            headerHeight = SCREEN_WIDTH;
        } else if (is_iPhone6) {
            headerHeight = SCREEN_WIDTH - kMargin;
        }
        
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, headerHeight);
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setProductionType:(WXYZ_ProductionType)productionType
{
    _productionType = productionType;
    [self createSubViews];
}

- (void)createSubViews
{
    self.backgroundColor = kWhiteColor;
    
    [self addSubview:self.bannerView];
    
    UIImageView *bannerBottonView = [[UIImageView alloc] init];
    bannerBottonView.image = [UIImage imageNamed:@"banner_bottom_line.png"];
    [self addSubview:bannerBottonView];
    
    [bannerBottonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.bannerView.mas_bottom).with.offset(1);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH, 800, 57));
    }];
    
    self.menuBarView = [[UIView alloc] init];
    self.menuBarView.backgroundColor = kWhiteColor;
    [self addSubview:self.menuBarView];
    
    [self.menuBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_WIDTH / 5 - kQuarterMargin);
    }];
}

- (YJBannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [YJBannerView bannerViewWithFrame:CGRectMake(0, 0, self.width, self.height - (SCREEN_WIDTH / 5)) dataSource:self delegate:self emptyImage:HoldImage placeholderImage:HoldImage selectorString:NSStringFromSelector(@selector(setImageWithURL:placeholder:))];
        _bannerView.repeatCount = 9999;
        _bannerView.pageControlAliment = PageControlAlimentCenter;
        _bannerView.autoDuration = 5.0f;
        _bannerView.pageControlStyle = PageControlCustom;
        _bannerView.pageControlDotSize = CGSizeMake(10, 5);
        _bannerView.pageControlBottomMargin = 15;
        _bannerView.customPageControlHighlightImage = [UIImage imageNamed:@"pageControlS"];
        _bannerView.customPageControlNormalImage = [UIImage imageNamed:@"pageControlN"];
    }
    return _bannerView;
}

- (NSArray *)bannerViewImages:(YJBannerView *)bannerView
{
    NSMutableArray *t_arr = [NSMutableArray array];
    for (WXYZ_BannerModel *t_model in self.mallCenterModel.banner) {
        [t_arr addObject:t_model.image];
    }
    return t_arr;
}

// 代理方法 点击了哪个bannerView 的 第几个元素
- (void)bannerView:(YJBannerView *)bannerView didSelectItemAtIndex:(NSInteger)index
{
    if (self.bannerrImageClickBlock) {
        self.bannerrImageClickBlock([self.self.mallCenterModel.banner objectOrNilAtIndex:index]);
    }
}

- (NSArray *)bannerViewRegistCustomCellClass:(YJBannerView *)bannerView
{
    return @[[YJMallCollectionViewCell class]];
}

/** 根据 Index 选择使用哪个 reuseIdentifier */
- (Class)bannerView:(YJBannerView *)bannerView reuseIdentifierForIndex:(NSInteger)index
{
    return [YJMallCollectionViewCell class];
}

/** 自定义 View 刷新数据或者其他配置 */
- (UICollectionViewCell *)bannerView:(YJBannerView *)bannerView customCell:(UICollectionViewCell *)customCell index:(NSInteger)index
{
    YJMallCollectionViewCell *cell = (YJMallCollectionViewCell *)customCell;
    cell.bannerModel = [self.mallCenterModel.banner objectOrNilAtIndex:index];
    return cell;
}

- (void)menuButtonClick:(WXYZ_CustomButton *)sender
{
    if (self.menuButtonClickBlock) {
        if ([sender.buttonTag isEqualToString:@"free"]) {
            self.menuButtonClickBlock(WXYZ_MenuButtonTypeFree, sender.buttonTitle?:@"");
        }
        
        if ([sender.buttonTag isEqualToString:@"finished"]) {
         self.menuButtonClickBlock(WXYZ_MenuButtonTypeFinish, sender.buttonTitle?:@"");
        }
        
        if ([sender.buttonTag isEqualToString:@"category"]) {
         self.menuButtonClickBlock(WXYZ_MenuButtonTypeClass, sender.buttonTitle?:@"");
        }
        
        if ([sender.buttonTag isEqualToString:@"rank"]) {
         self.menuButtonClickBlock(WXYZ_MenuButtonTypeRank, sender.buttonTitle?:@"");
        }
        
        if ([sender.buttonTag isEqualToString:@"vip"]) {
         self.menuButtonClickBlock(WXYZ_MenuButtonTypeMember, sender.buttonTitle?:@"");
        }
    }
}

- (void)setMallCenterModel:(WXYZ_MallCenterModel *)mallCenterModel
{
    _mallCenterModel = mallCenterModel;
    
    [self.menuBarView removeAllSubviews];
    
    [self.bannerView reloadData];
    
    for (int i = 0; i < mallCenterModel.menus_tabs.count; i ++) {
        WXYZ_MallCenterMenusModel *t_model = [mallCenterModel.menus_tabs objectAtIndex:i];
        
        WXYZ_CustomButton *button = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:t_model.title?:@"" buttonImageName:t_model.icon?:@"" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom showMaskView:YES];
        button.graphicDistance = 0;
        button.buttonImageScale = 0.6;
        button.buttonTitleFont = kFont13;
        button.buttonTag = t_model.action;
        [button addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuBarView addSubview:button];
        
        CGFloat buttonWidth = SCREEN_WIDTH / mallCenterModel.menus_tabs.count;
        CGFloat buttonHeight = SCREEN_WIDTH / 5 - kQuarterMargin;
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(i * buttonWidth);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(buttonWidth);
            make.height.mas_equalTo(buttonHeight);
        }];
    }
}

@end
