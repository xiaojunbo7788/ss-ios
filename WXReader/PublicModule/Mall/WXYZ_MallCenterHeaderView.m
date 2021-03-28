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
#import "WXYZ_WebViewViewController.h"
@interface WXYZ_MallCenterHeaderView () <YJBannerViewDelegate, YJBannerViewDataSource,UUMarqueeViewDelegate>

@property (nonatomic, strong) YJBannerView *bannerView;

@property (nonatomic, strong) UIView *menuBarView;

@property (nonatomic, strong) UIView *noticeView;

@property (nonatomic, assign) CGFloat oHeight;


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
        self.oHeight = headerHeight;
        headerHeight = headerHeight + 50+10+5;
        
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
        make.top.mas_equalTo(bannerBottonView.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_WIDTH / 5 - kQuarterMargin);
    }];
    
    self.noticeView = [[UIView alloc] init];
    self.noticeView.layer.masksToBounds = true;
    self.noticeView.layer.borderColor = WX_COLOR_WITH_HEX(0xEEEEEE).CGColor;
    self.noticeView.layer.borderWidth = 0.5;
    self.noticeView.layer.cornerRadius = 1;
    [self addSubview:self.noticeView];
    
    [self.noticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(self.oHeight+10);
        make.bottom.mas_equalTo(self).offset(-5);
    }];
    
    self.upwardMultiMarqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(10.0f, 2, SCREEN_WIDTH - 20 - 20, 27*3)];
    _upwardMultiMarqueeView.delegate = self;
    _upwardMultiMarqueeView.timeIntervalPerScroll = 3.0f;
    _upwardMultiMarqueeView.timeDurationPerScroll = 0.5f;
    _upwardMultiMarqueeView.touchEnabled = YES;
    [self.noticeView addSubview:_upwardMultiMarqueeView];
}

- (YJBannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [YJBannerView bannerViewWithFrame:CGRectMake(0, 0, self.width, self.oHeight - (SCREEN_WIDTH / 5)) dataSource:self delegate:self emptyImage:HoldImage placeholderImage:HoldImage selectorString:NSStringFromSelector(@selector(setImageWithURL:placeholder:))];
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
    [_upwardMultiMarqueeView reloadData];
}

#pragma mark - UUMarqueeViewDelegate
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    return 1;
}

- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView {
    return self.mallCenterModel.announcement.count;
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    // for upwardMultiMarqueeView
    itemView.backgroundColor = [UIColor clearColor];
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(itemView.bounds) - 80,50)];
    content.font = [UIFont systemFontOfSize:15.0f];
    content.textColor = [UIColor grayColor];
    content.tag = 1001;
    [itemView addSubview:content];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.masksToBounds = true;
    button.layer.cornerRadius = 28/2;
    button.frame = CGRectMake(CGRectGetWidth(itemView.bounds) - 74, (50 - 28)/2, 74, 28);
    [button setTitle:@"立即领取" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.backgroundColor = WX_RGB_COLOR(220,146,65,1);
    [itemView addSubview:button];
//    [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // for upwardMultiMarqueeView
    UILabel *content = [itemView viewWithTag:1001];
    content.text = self.mallCenterModel.announcement[index].title;
}

- (CGFloat)itemViewHeightAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // for upwardDynamicHeightMarqueeView
    UILabel *content = [[UILabel alloc] init];
    content.numberOfLines = 0;
    content.font = [UIFont systemFontOfSize:10.0f];
    content.text = self.mallCenterModel.announcement[index].title;
//    CGSize contentFitSize = [content sizeThatFits:CGSizeMake(CGRectGetWidth(marqueeView.frame) - 5.0f - 16.0f - 5.0f, MAXFLOAT)];
//    return contentFitSize.height + 20.0f;
    return  25;
}

- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // for leftwardMarqueeView
    UILabel *content = [[UILabel alloc] init];
    content.font = [UIFont systemFontOfSize:10.0f];
    content.text = self.mallCenterModel.announcement[index].title;
    return (5.0f + 16.0f + 5.0f) + content.intrinsicContentSize.width;  // icon width + label width (it's perfect to cache them all)
}

- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    WXYZ_NoticeModel *model = self.mallCenterModel.announcement[index];
    if ([model.open_type intValue] == 1) {
        //webview
        WXYZ_WebViewViewController *vc = [[WXYZ_WebViewViewController alloc] init];
        vc.URLString = model.link_url;
        vc.isPresentState = NO;
        [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:vc animated:YES];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.link_url] options:@{} completionHandler:nil];
    }
   
}

@end
