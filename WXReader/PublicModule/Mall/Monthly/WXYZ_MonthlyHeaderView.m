//
//  WXYZ_MonthlyHeaderView.m
//  WXReader
//
//  Created by Andrew on 2018/6/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_MonthlyHeaderView.h"
#import "WXYZ_DiscoverHeaderCollectionViewCell.h"
#import "YJBannerView.h"

#define UserView_Height 80

#define Button_Width 70

@interface WXYZ_MonthlyHeaderView () <YJBannerViewDelegate, YJBannerViewDataSource>

@property (nonatomic, strong) YJBannerView *bannerView;

@property (nonatomic, strong) NSMutableArray *bannerImageArr;

@end

@implementation WXYZ_MonthlyHeaderView
{
    UIImageView *userAvatar;
    UILabel *userNickname;
    UIImageView *vipImageView;
    UILabel *noticeLabel;
    UIButton *memberButton;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = kWhiteColor;
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, UserView_Height + kMoreHalfMargin + kMoreHalfMargin + SCREEN_WIDTH / 5);
        self.bannerImageArr = [NSMutableArray array];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    //banner
    [self addSubview:self.bannerView];
    
    userAvatar = [[UIImageView alloc] initWithCornerRadiusAdvance:(UserView_Height - 2 * kHalfMargin) / 2 rectCornerType:UIRectCornerAllCorners];
    userAvatar.image = HoldUserAvatar;
    [self addSubview:userAvatar];
    
    [userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(self.bannerView.mas_bottom).with.offset(kMoreHalfMargin);
        make.width.height.mas_equalTo(UserView_Height - 2 * kHalfMargin);
    }];
    
    userNickname = [[UILabel alloc] init];
    userNickname.backgroundColor = kGrayViewColor;
    userNickname.textColor = kBlackColor;
    userNickname.font = kMainFont;
    userNickname.textAlignment = NSTextAlignmentLeft;
    [self addSubview:userNickname];
    
    [userNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userAvatar.mas_right).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(userAvatar.mas_centerY).with.offset(- 3);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(20);
    }];
    
    vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_vip_normal"]];
    vipImageView.hidden = YES;
    [self addSubview:vipImageView];
    
    [vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userNickname.mas_right).with.offset(kQuarterMargin);
        make.centerY.mas_equalTo(userNickname.mas_centerY);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(kGeometricWidth(12, 138, 48));
    }];
    
    memberButton = [UIButton buttonWithType:UIButtonTypeCustom];
    memberButton.hidden = YES;
    memberButton.layer.cornerRadius = 4;
    [memberButton.titleLabel setFont:kFont12];
    [memberButton setTitle:@"开通" forState:UIControlStateNormal];
    [memberButton setTitleColor:kColorRGB(120, 79, 18) forState:UIControlStateNormal];
    [memberButton setBackgroundImage:[UIImage imageNamed:@"monthly_member"] forState:UIControlStateNormal];
    [memberButton addTarget:self action:@selector(jumpToMember) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:memberButton];
    
    [memberButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(userAvatar.mas_centerY);
        make.width.mas_equalTo(kGeometricWidth(30, 210, 80));
        make.height.mas_equalTo(30);
    }];
    
    noticeLabel = [[UILabel alloc] init];
    noticeLabel.backgroundColor = kGrayViewColor;
    noticeLabel.textColor = kGrayTextColor;
    noticeLabel.font = kFont12;
    noticeLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:noticeLabel];
    
    [noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userNickname.mas_left);
        make.top.mas_equalTo(userAvatar.mas_centerY).with.offset(3);
        make.right.mas_equalTo(memberButton.mas_left).with.offset(- kHalfMargin);
        make.height.mas_equalTo(userNickname.mas_height);
    }];
    
    // 横线
    UIView *line = [[UIView alloc] init];
    line.hidden = NO;
    line.backgroundColor = kGrayLineColor;
    
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kHalfMargin);
        make.top.mas_equalTo(userAvatar.mas_bottom).with.offset(kMoreHalfMargin);
        make.right.mas_equalTo(self.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(kCellLineHeight);
    }];
}

- (void)setUserInfoModel:(WXYZ_MonthlyInfoModel *)userInfoModel
{
    _userInfoModel = userInfoModel;
    
    [userAvatar setImageWithURL:[NSURL URLWithString:userInfoModel.avatar?:@""] placeholder:HoldUserAvatar options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    noticeLabel.text = userInfoModel.vip_desc;
    if (userInfoModel.nickname.length == 0 || !userInfoModel.nickname) {
        userNickname.text = @"未登录";
        vipImageView.hidden = YES;
    } else {
        userNickname.text = userInfoModel.nickname?:@"";
        vipImageView.hidden = NO;
        if (userInfoModel.baoyue_status == 1) {
            noticeLabel.text = userInfoModel.expiry_date.length > 0 ? userInfoModel.expiry_date :userInfoModel.vip_desc;
            vipImageView.image = [UIImage imageNamed:@"public_vip_select"];
            [memberButton setTitle:@"续费" forState:UIControlStateNormal];
        } else {
            vipImageView.image = [UIImage imageNamed:@"public_vip_normal"];
            [memberButton setTitle:@"开通" forState:UIControlStateNormal];
        }
    }
    userNickname.backgroundColor = [UIColor whiteColor];
    [userNickname mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:userNickname]);
    }];
    
    noticeLabel.backgroundColor = [UIColor whiteColor];
    
    memberButton.hidden = NO;
}

- (void)setPrivilege:(NSArray<WXYZ_PrivilegeModel *> *)privilege
{
    if (!_privilege && privilege) {
        for (int i = 0; i < privilege.count; i ++) {
            
            WXYZ_PrivilegeModel *t_model = [privilege objectAtIndex:i];
            
            WXYZ_CustomButton *button = [[WXYZ_CustomButton alloc] initWithFrame:CGRectZero buttonTitle:t_model.label?:@"" buttonImageName:t_model.icon?:@"" buttonIndicator:WXYZ_CustomButtonIndicatorTitleBottom showMaskView:YES];
            button.graphicDistance = 0;
            button.buttonImageScale = 0.6;
            button.buttonTitleFont = kFont13;
            [button addTarget:self action:@selector(functionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [self addSubview:button];
            
            CGFloat buttonWidth = SCREEN_WIDTH / privilege.count;
            CGFloat buttonHeight = SCREEN_WIDTH / 5;
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(i * buttonWidth);
                make.top.mas_equalTo(userAvatar.mas_bottom).with.offset(kMoreHalfMargin * 2);
                make.width.mas_equalTo(buttonWidth);
                make.height.mas_equalTo(buttonHeight);
            }];
        }
    }
    _privilege = privilege;
}

- (void)setBanner:(NSArray<WXYZ_BannerModel *> *)banner
{
    if (banner) {
        _banner = banner;
        
        [_bannerImageArr removeAllObjects];
        
        if (banner.count == 0) {
            self.bannerView.frame = CGRectMake(0, kHalfMargin, SCREEN_WIDTH, 0);
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, UserView_Height + kMoreHalfMargin + kMoreHalfMargin + SCREEN_WIDTH / 5);
            [userAvatar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.bannerView.mas_bottom).with.offset(CGFLOAT_MIN);
            }];
        } else {
            self.bannerView.frame = CGRectMake(0, kHalfMargin, SCREEN_WIDTH, SCREEN_WIDTH / 4);
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 4 + kMoreHalfMargin + UserView_Height + kMoreHalfMargin + kMoreHalfMargin + SCREEN_WIDTH / 5);
            [userAvatar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.bannerView.mas_bottom).with.offset(kMoreHalfMargin);
            }];
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
        _bannerView = [YJBannerView bannerViewWithFrame:CGRectMake(0, kHalfMargin, SCREEN_WIDTH, SCREEN_WIDTH / 4) dataSource:self delegate:self emptyImage:HoldImage placeholderImage:HoldImage selectorString:NSStringFromSelector(@selector(setImageWithURL:placeholder:))];
        _bannerView.pageControlAliment = PageControlAlimentCenter;
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

- (void)jumpToMember
{
    if (self.functionButtonClickBlock) {
        self.functionButtonClickBlock([[WXYZ_PrivilegeModel alloc] init]);
    }
}

- (void)functionButtonClick:(UIButton *)sender
{
    if (self.functionButtonClickBlock) {
        self.functionButtonClickBlock([self.privilege objectAtIndex:sender.tag]);
    }
}

@end
