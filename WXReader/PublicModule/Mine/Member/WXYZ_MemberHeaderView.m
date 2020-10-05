//
//  WXYZ_MemberHeaderView.m
//  WXReader
//
//  Created by Andrew on 2018/7/23.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MemberHeaderView.h"
#import "WXYZ_DiscoverHeaderCollectionViewCell.h"

@interface WXYZ_MemberHeaderView ()<YJBannerViewDelegate, YJBannerViewDataSource>

@property (nonatomic, strong) UIView *bgView;

@end


@implementation WXYZ_MemberHeaderView
{
    UIImageView *userBackImageView;
    
    UIImageView *userAvatar;
    UILabel *userNickname;
    UIImageView *vipImageView;
    UILabel *noticeLabel;
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
        make.height.mas_equalTo((PUB_NAVBAR_HEIGHT + kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) + 30));
    }];
    
    userBackImageView = [[UIImageView alloc] init];
    userBackImageView.image = [UIImage imageNamed:@"member_bg"];
    [self.bgView addSubview:userBackImageView];
    
    [userBackImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215));
    }];
    
    userAvatar = [[UIImageView alloc] initWithCornerRadiusAdvance:(kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) - kMargin) / 2 rectCornerType:UIRectCornerAllCorners];
    [userBackImageView addSubview:userAvatar];
    
    [userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.centerY.mas_equalTo(userBackImageView.mas_centerY);
        make.width.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) - kMargin);
    }];
    
    userNickname = [[UILabel alloc] init];
    userNickname.backgroundColor = [UIColor clearColor];
    userNickname.textColor = kBlackColor;
    userNickname.font = kMainFont;
    userNickname.textAlignment = NSTextAlignmentLeft;
    [userBackImageView addSubview:userNickname];
    
    [userNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userAvatar.mas_right).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(userAvatar.mas_centerY);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(20);
    }];
    
    vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_vip_normal"]];
    vipImageView.hidden = YES;
    [userBackImageView addSubview:vipImageView];
    
    [vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userNickname.mas_right).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(userNickname.mas_centerY);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(kGeometricWidth(12, 138, 48));
    }];
    
    noticeLabel = [[UILabel alloc] init];
    noticeLabel.backgroundColor = [UIColor clearColor];
    noticeLabel.textColor = kColorRGB(225, 162, 70);
    noticeLabel.font = kFont11;
    noticeLabel.textAlignment = NSTextAlignmentLeft;
    [userBackImageView addSubview:noticeLabel];
    
    [noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userNickname.mas_left);
        make.top.mas_equalTo(userAvatar.mas_centerY).with.offset(6);
        make.right.mas_equalTo(userBackImageView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(userNickname.mas_height);
    }];
    
    //banner
    [self addSubview:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(SCREEN_WIDTH / 4);
    }];
    
}

- (void)setUserModel:(WXYZ_MonthlyInfoModel *)userModel
{
    if (!userModel) {
        userNickname.text = @"未登录";
        noticeLabel.text = @"开通会员免费畅读会员书库";
        return;
    }
    
    [userAvatar setImageWithURL:[NSURL URLWithString:userModel.avatar?:@""] placeholder:HoldUserAvatar options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    noticeLabel.text = userModel.vip_desc;
    
    if (userModel.nickname.length == 0 || !userModel.nickname || !WXYZ_UserInfoManager.isLogin) {
        userNickname.text = @"未登录";
        vipImageView.hidden = YES;
    } else {
        userNickname.text = userModel.nickname?:@"";
        vipImageView.hidden = NO;
        if (userModel.baoyue_status == 1) {
            noticeLabel.text = userModel.expiry_date.length > 0 ? userModel.expiry_date :userModel.vip_desc;
            vipImageView.image = [UIImage imageNamed:@"public_vip_select"];
        } else {
            vipImageView.image = [UIImage imageNamed:@"public_vip_normal"];
        }
    }
    [userNickname mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:userNickname maxWidth:SCREEN_WIDTH * 0.7]);
    }];
}


- (void)setBanner:(NSArray<WXYZ_BannerModel *> *)banner
{
    if (banner) {
        _banner = banner;
        
        [_bannerImageArr removeAllObjects];
        
        if (banner.count == 0) {
//            self.bannerView.frame = CGRectMake(0, kHalfMargin, SCREEN_WIDTH, 0);
            _bannerView.hidden = true;
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, (PUB_NAVBAR_HEIGHT + kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) + 30));
        } else {
             _bannerView.hidden = false;
//            self.bannerView.frame = CGRectMake(0, kHalfMargin, SCREEN_WIDTH, SCREEN_WIDTH / 4);
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, (PUB_NAVBAR_HEIGHT + kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) + 30)+SCREEN_WIDTH / 4+20);
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
        _bannerView = [YJBannerView bannerViewWithFrame:CGRectMake(0, (PUB_NAVBAR_HEIGHT + kGeometricHeight(SCREEN_WIDTH - kMargin, 1053, 215) + 30), SCREEN_WIDTH, SCREEN_WIDTH / 4 + 20) dataSource:self delegate:self emptyImage:HoldImage placeholderImage:HoldImage selectorString:NSStringFromSelector(@selector(setImageWithURL:placeholder:))];
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
