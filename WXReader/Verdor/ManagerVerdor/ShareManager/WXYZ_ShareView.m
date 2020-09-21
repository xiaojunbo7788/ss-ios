//
//  ZYShareView.m
//  
//
//  Created by ZZY on 16/3/28.
//
//

#import "WXYZ_ShareView.h"
#import "WXYZ_ShareViewCell.h"
#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>
#endif
#import "UIView+BorderLine.h"
#import "UIView+LayoutCallback.h"

#define ZY_ItemCellHeight           100.f   // 每个item的高度

@interface WXYZ_ShareView () <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UITapGestureRecognizer *tap;
}

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *mainCollectionViewFlowLayout;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSMutableArray *dataSources;

@end

@implementation WXYZ_ShareView

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (void)initialize
{
    self.dataSources = [NSMutableArray array];
#if WX_W_Share_Mode
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
        [self.dataSources addObject:@[@"微信好友", @"login_wechat", [NSNumber numberWithInteger:WXYZ_ShareStateWeChat]]];
    }
    
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatTimeLine]) {
        [self.dataSources addObject:@[@"朋友圈", @"share_wechat_timeline", [NSNumber numberWithInteger:WXYZ_ShareStateWeChatTimeLine]]];
    }
#endif
    
#if WX_Q_Share_Mode
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]) {
        [self.dataSources addObject:@[@"QQ好友", @"login_qq", [NSNumber numberWithInteger:WXYZ_ShareStateQQ]]];
    }
    
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]) {
        [self.dataSources addObject:@[@"QQ空间", @"share_qzone", [NSNumber numberWithInteger:WXYZ_ShareStateQQZone]]];
    }
#endif
    
    if (self.dataSources.count == 0) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"您尚未安装任何可分享的应用"];
        return;
    }
    
    self.userInteractionEnabled = YES;
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = kBlackTransparentAlphaColor(0);
    [kMainWindow addSubview:self];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidden)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    self.mainCollectionView.scrollEnabled = YES;
    if (self.dataSources.count <= 4) {
        self.mainCollectionView.scrollEnabled = NO;
    }
}

- (void)createSubviews
{
    [self addSubview:self.backView];
    
    WS(weakSelf)
    self.titleLabel.frameBlock = ^(UIView * _Nonnull view) {
        // 设置文字分割线
        CALayer *splitLine = [CALayer layer];
        splitLine.backgroundColor = kGrayLineColor.CGColor;
        splitLine.anchorPoint = CGPointMake(0, 0);
        splitLine.bounds = CGRectMake(0, 0, 160, 1);
        splitLine.center = CGPointMake(weakSelf.titleLabel.centerX, weakSelf.titleLabel.centerY);
        [weakSelf.backView.layer addSublayer:splitLine];
        [weakSelf.backView bringSubviewToFront:view];
    };
    
    [self.backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kHalfMargin);
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(40);
    }];
    
    [self.backView addSubview:self.mainCollectionView];
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).with.offset(kHalfMargin);
        make.width.mas_equalTo(self.backView.mas_width);
        make.height.mas_equalTo(ZY_ItemCellHeight);
    }];
    
    [self.backView addSubview:self.cancelButton];
    [self.backView bringSubviewToFront:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.mainCollectionView.mas_bottom);
        make.width.mas_equalTo(self.backView.mas_width);
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT - kHalfMargin);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.cancelButton addBorderLineWithBorderWidth:kCellLineHeight borderColor:kGrayLineColor cornerRadius:0 borderType:UIBorderSideTypeTop];
    });
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_ShareViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WXYZ_ShareViewCell" forIndexPath:indexPath];
    cell.sourceArray = [self.dataSources objectOrNilAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *t_arr = [self.dataSources objectOrNilAtIndex:indexPath.row];
    WXYZ_ShareState state = (WXYZ_ShareState)[[t_arr objectOrNilAtIndex:2] integerValue];
    if (self.clickHandler) {
        self.clickHandler(state);
    }
    [self hidden];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSources.count <= 4) {
        return CGSizeMake((SCREEN_WIDTH - 2 * kHalfMargin) / self.dataSources.count, ZY_ItemCellHeight);
    }
    return CGSizeMake(SCREEN_WIDTH / 4.7, ZY_ItemCellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (self.dataSources.count <= 4) {
        return UIEdgeInsetsMake(0, kHalfMargin, 0, kHalfMargin);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - public method

- (void)show
{
    if (self.dataSources.count == 0) {
        return;
    }
    
    WS(weakSelf)
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        weakSelf.backgroundColor = kBlackTransparentAlphaColor(0.5);
        weakSelf.backView.frame = CGRectMake(0, SCREEN_HEIGHT - (kHalfMargin + 40 + kHalfMargin + ZY_ItemCellHeight + PUB_TABBAR_HEIGHT - kHalfMargin), SCREEN_WIDTH, kHalfMargin + 40 + kHalfMargin + ZY_ItemCellHeight + PUB_TABBAR_HEIGHT - kHalfMargin);
    }];
}

- (void)hidden
{
    WS(weakSelf)
    [UIView animateWithDuration:kAnimatedDurationFast animations:^{
        weakSelf.backgroundColor = kBlackTransparentAlphaColor(0);
        weakSelf.backView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 40 + ZY_ItemCellHeight + PUB_TABBAR_HEIGHT);
    } completion:^(BOOL finished) {
        [weakSelf removeFromKeyWindow];
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isEqual:self]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)removeFromKeyWindow
{
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (UIView *)backView
{
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.userInteractionEnabled = YES;
        _backView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, kHalfMargin + 40 + kHalfMargin + ZY_ItemCellHeight + PUB_TABBAR_HEIGHT - kHalfMargin);
        _backView.backgroundColor = [UIColor whiteColor];
        [_backView addRoundingCornersWithRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
        _backView.clipsToBounds = YES;
    }
    return _backView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = kGrayTextColor;
        _titleLabel.text = @"分享至";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = kMainFont;
    }
    return _titleLabel;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        [_cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET / 2, 0)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:kMainFont];
        [_cancelButton addTarget:self action:@selector(hidden) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
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
        if (@available(iOS 11.0, *)) {
            _mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [_mainCollectionView registerClass:[WXYZ_ShareViewCell class] forCellWithReuseIdentifier:@"WXYZ_ShareViewCell"];
    }
    return _mainCollectionView;
}

- (UICollectionViewFlowLayout *)mainCollectionViewFlowLayout
{
    if (!_mainCollectionViewFlowLayout) {
        _mainCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollectionViewFlowLayout.minimumInteritemSpacing = 0;
        _mainCollectionViewFlowLayout.minimumLineSpacing = 0;
        _mainCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _mainCollectionViewFlowLayout;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
