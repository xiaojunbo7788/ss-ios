//
//  WXYZ_RackCenterHeaderView.m
//  WXReader
//
//  Created by Andrew on 2019/6/13.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_RackCenterHeaderView.h"
#import "WXYZ_RackHeaderCollectionViewCell.h"

#import "WXYZ_SignModel.h"

#import "WXYZ_AnnouncementView.h"
#import "YJBannerView.h"
#import "WXYZ_SignAlertView.h"

@interface WXYZ_RackCenterHeaderView () <YJBannerViewDelegate, YJBannerViewDataSource>

@property (nonatomic, strong) YJBannerView *recommendBannerView;

@property (nonatomic, strong) WXYZ_AnnouncementView *announceBannerView;

@property (nonatomic, strong) NSMutableArray *bannerArray;

@end

@implementation WXYZ_RackCenterHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    self.backgroundColor = kWhiteColor;
    
    [self addSubview:self.recommendBannerView];
    [self.recommendBannerView reloadData];
    
    [self addSubview:self.announceBannerView];
    
    [self.announceBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin + kQuarterMargin);
        make.top.mas_equalTo(self.recommendBannerView.mas_bottom).with.offset(kHalfMargin);
        make.right.mas_equalTo(self.recommendBannerView.mas_right).with.offset(- kHalfMargin - kQuarterMargin);
        make.height.mas_equalTo(kLabelHeight);
    }];
    
#if WX_Sign_Mode
    WXYZ_CustomButton *collectionButton = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:@"签到" buttonImageName:@"public_sign_in" buttonIndicator:WXYZ_CustomButtonIndicatorTitleRight];
    collectionButton.graphicDistance = 5;
    collectionButton.buttonImageScale = 0.45;
    collectionButton.buttonTintColor = kMainColor;
    [collectionButton addTarget:self action:@selector(rackCollectionClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:collectionButton];
    
    [collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.announceBannerView.mas_right).with.offset(- kQuarterMargin);
        make.centerY.mas_equalTo(self.announceBannerView.mas_centerY);
        make.height.mas_equalTo(self.announceBannerView.mas_height);
        make.width.mas_equalTo(80);
    }];
#endif
}

- (WXYZ_AnnouncementView *)announceBannerView
{
    if (!_announceBannerView) {
        WS(weakSelf)
        _announceBannerView = [[WXYZ_AnnouncementView alloc] init];
        _announceBannerView.layer.cornerRadius = kLabelHeight / 2;
        _announceBannerView.backgroundColor = kGrayViewColor;
        _announceBannerView.clickAdBlock = ^(NSString *path, NSUInteger index) {
            if (weakSelf.adBannerClickBlock) {
                WXYZ_AnnouncementModel *t_ann = [weakSelf.rackModel.announcement objectAtIndex:index];
                weakSelf.adBannerClickBlock(t_ann.title, t_ann.content);
            }
        };
    }
    return _announceBannerView;
}

- (YJBannerView *)recommendBannerView
{
    if (!_recommendBannerView) {
        _recommendBannerView = [YJBannerView bannerViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kGeometricHeight(SCREEN_WIDTH, 3, 1)) dataSource:self delegate:self emptyImage:nil placeholderImage:nil selectorString:NSStringFromSelector(@selector(setImageWithURL:placeholder:))];
        _recommendBannerView.backgroundColor = kWhiteColor;
        _recommendBannerView.repeatCount = 9999;
        _recommendBannerView.autoDuration = 5.0f;
        _recommendBannerView.pageControlAliment = PageControlAlimentRight;
        _recommendBannerView.pageControlStyle = PageControlCustom;
        _recommendBannerView.pageControlDotSize = CGSizeMake(5, 5);
        _recommendBannerView.pageControlBottomMargin = 20;
        _recommendBannerView.pageControlHorizontalEdgeMargin = 25;
        _recommendBannerView.pageControlPadding = 3;
        _recommendBannerView.customPageControlHighlightImage = [UIImage imageNamed:@"pageControl_H"];
        _recommendBannerView.customPageControlNormalImage = [UIImage imageNamed:@"pageControl_N"];
    }
    return _recommendBannerView;
}

- (NSMutableArray *)bannerArray
{
    if (!_bannerArray) {
        _bannerArray = [NSMutableArray array];
        [_bannerArray addObject:@""];
    }
    return _bannerArray;
}

// 将网络图片或者本地图片 或者混合数组
- (NSArray *)bannerViewImages:(YJBannerView *)bannerView
{
    return self.bannerArray;
}

- (NSArray *)bannerViewRegistCustomCellClass:(YJBannerView *)bannerView
{
    return @[[WXYZ_RackHeaderCollectionViewCell class]];
}

/** 根据 Index 选择使用哪个 reuseIdentifier */
- (Class)bannerView:(YJBannerView *)bannerView reuseIdentifierForIndex:(NSInteger)index
{
    return [WXYZ_RackHeaderCollectionViewCell class];
}

/** 自定义 View 刷新数据或者其他配置 */
- (UICollectionViewCell *)bannerView:(YJBannerView *)bannerView customCell:(UICollectionViewCell *)customCell index:(NSInteger)index
{
    WXYZ_RackHeaderCollectionViewCell *cell = (WXYZ_RackHeaderCollectionViewCell *)customCell;
    cell.productionModel = [_rackModel.recommendList objectOrNilAtIndex:index];
    cell.productionType = self.productionType;
    return cell;
}

// 代理方法 点击了哪个bannerView 的 第几个元素
- (void)bannerView:(YJBannerView *)bannerView didSelectItemAtIndex:(NSInteger)index
{
    if ([[self.bannerArray objectAtIndex:index] length] > 0) {
        WS(weakSelf)
        if (self.recommendBannerClickBlock) {
            self.recommendBannerClickBlock([weakSelf.rackModel.recommendList objectAtIndex:index].production_id);
        }
    }
}

- (void)rackCollectionClick
{
    if (!WXYZ_UserInfoManager.isLogin) {
        
        [WXYZ_LoginViewController presentLoginView];
        
        return;
    }
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Sign_Click parameters:nil model:WXYZ_SignModel.class success:^(BOOL isSuccess, WXYZ_SignModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            if ((t_model.book.count > 0 || t_model.comic.count > 0) && t_model.award.length > 0 && t_model.tomorrow_award.length > 0) {
                
                NSMutableArray *t_arr = [NSMutableArray array];
                
                for (WXYZ_ProductionModel *t in t_model.book) {
                    t.productionType = WXYZ_ProductionTypeBook;
                    [t_arr addObject:t];
                }
                
                for (WXYZ_ProductionModel *t in t_model.comic) {
                    t.productionType = WXYZ_ProductionTypeComic;
                    [t_arr addObject:t];
                }
                
                for (WXYZ_ProductionModel *t in t_model.audio) {
                    t.productionType = WXYZ_ProductionTypeAudio;
                    [t_arr addObject:t];
                }
                
                WXYZ_SignAlertView *alert = [[WXYZ_SignAlertView alloc] init];
                alert.alertViewTitle = t_model.award;
                alert.alertViewDetailContent = t_model.tomorrow_award;
                alert.bookList = [t_arr copy];
                [alert showAlertView];
            }
        } else {
            !weakSelf.collectionClickBlock ?: weakSelf.collectionClickBlock();
        }
    } failure:nil];
}

- (void)setRackModel:(WXYZ_RackCenterModel *)rackModel
{
    if (_rackModel != rackModel) {
        _rackModel = rackModel;
        // 公告
        if (rackModel.announcement.count > 0) {
            self.announceBannerView.modelArr = rackModel.announcement;
            self.announceBannerView.hidden = NO;
        } else {
            self.announceBannerView.hidden = YES;
        }
        
        // 设置推荐
        [self.bannerArray removeAllObjects];
        
        for (WXYZ_ProductionModel *model in rackModel.recommendList) {
            NSString *imageURL = (model.vertical_cover.length > 0?model.vertical_cover:model.horizontal_cover)?:model.cover?:@"";
            
            [self.bannerArray addObject:imageURL];
        }
        
        [self.recommendBannerView reloadData];
    }
}

@end
