//
//  WXYZ_GiftView.m
//  WXReader
//
//  Created by LL on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GiftView.h"

#import "UIView+LayoutCallback.h"

#import "SGPageTitleView.h"
#import "WXYZ_GiftRewardView.h"
#import "WXYZ_GiftMonthlyPassView.h"

#import "AppDelegate.h"

@interface WXYZ_GiftView ()<SGPageTitleViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIView *mainView;

@property (nonatomic, weak) UIView *backView;

@property (nonatomic, weak) SGPageTitleView *pageTitleView;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@property (nonatomic, weak) WXYZ_GiftRewardView *rewardView;

@property (nonatomic, weak) WXYZ_GiftMonthlyPassView *monthlyPassView;

@property (nonatomic, strong) NSMutableArray<NSString *> *titleArr;

/// mainView视图约束
@property (nonatomic, strong) MASConstraint *mainViewConstraint;

@end

@implementation WXYZ_GiftView

- (instancetype)initWithFrame:(CGRect)frame bookModel:(WXYZ_ProductionModel *)bookModel {
    if (self = [super initWithFrame:frame]) {
        self.bookModel = bookModel;
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    self.backgroundColor = kBlackTransparentColor;
    [[WXYZ_ViewHelper getCurrentViewController].view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([WXYZ_ViewHelper getCurrentViewController].view);
    }];
    
    UIView *backView = [[UIView alloc] init];
    self.backView = backView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [backView addGestureRecognizer:tap];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIView *mainView = [[UIView alloc] init];
    self.mainView = mainView;
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.frameBlock = ^(UIView * _Nonnull view) {
        UIBezierPath *corner = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(12.0, 12.0)];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = corner.CGPath;
        view.layer.mask = layer;
    };
    [self addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.mainViewConstraint = make.top.equalTo(backView.mas_bottom);
        make.left.width.equalTo(backView);
    }];

    SGPageTitleViewConfigure *pageConfigure = [[SGPageTitleViewConfigure alloc] init];
    pageConfigure.indicatorColor = kColorRGB(253, 154, 99);
    pageConfigure.indicatorStyle = SGIndicatorStyleDynamic;
    pageConfigure.indicatorHeight = 3;
    pageConfigure.indicatorFixedWidth = 20;
    pageConfigure.indicatorDynamicWidth = 20;
    pageConfigure.indicatorCornerRadius = 3.0;
    pageConfigure.indicatorToBottomDistance = 5;
    pageConfigure.titleFont = kFont15;
    pageConfigure.titleSelectedFont = kFont18;
    pageConfigure.titleColor = kGrayTextColor;
    pageConfigure.titleSelectedColor = kBlackColor;
    pageConfigure.showBottomSeparator = NO;
    
    AppDelegate *app = (AppDelegate *)kRCodeSync([UIApplication sharedApplication].delegate);
    NSMutableArray<NSString *> *titleArr = [NSMutableArray array];
    self.titleArr = titleArr;
    if (app.checkSettingModel.system_setting.novel_reward_switch == 1) {
        [titleArr addObject:@"打赏"];
    }
    
    if (app.checkSettingModel.system_setting.monthly_ticket_switch == 1) {
        [titleArr addObject:@"月票"];
    }
    
    SGPageTitleView *pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectZero delegate:self titleNames:titleArr configure:pageConfigure];
    self.pageTitleView = pageTitleView;
    pageTitleView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:pageTitleView];
    [pageTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainView).offset(0);
        make.centerX.equalTo(mainView);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(50);
    }];
    
    UIView *pageTitleSplitLine = [[UIView alloc] init];
    pageTitleSplitLine.backgroundColor = kGrayLineColor;
    [mainView addSubview:pageTitleSplitLine];
    [pageTitleSplitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(mainView);
        make.top.equalTo(pageTitleView.mas_bottom);
        make.height.mas_equalTo(kCellLineHeight);
    }];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    self.scrollView = scrollView;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.bounces = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    [mainView addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pageTitleSplitLine.mas_bottom);
        make.left.width.equalTo(mainView);
        make.height.mas_equalTo(271 + PUB_TABBAR_OFFSET);
    }];
    
    WXYZ_GiftRewardView *rewardView = [[WXYZ_GiftRewardView alloc] initWithBookModel:self.bookModel];
    self.rewardView = rewardView;
    rewardView.giftView = self;
    rewardView.backgroundColor = [UIColor clearColor];
    
    WXYZ_GiftMonthlyPassView *monthlyPassView = [[WXYZ_GiftMonthlyPassView alloc] initWithFrame:CGRectZero bookModel:self.bookModel];
    self.monthlyPassView = monthlyPassView;
    monthlyPassView.giftView = self;
    monthlyPassView.backgroundColor = [UIColor clearColor];
    
    
    if (app.checkSettingModel.system_setting.novel_reward_switch == 1 && app.checkSettingModel.system_setting.monthly_ticket_switch == 1) {
        [scrollView addSubview:rewardView];
        [scrollView addSubview:monthlyPassView];
        [rewardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.height.equalTo(scrollView);
        }];
        [monthlyPassView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.right.equalTo(scrollView);
            make.left.equalTo(rewardView.mas_right);
            make.width.equalTo(rewardView);
        }];
    } else if (app.checkSettingModel.system_setting.novel_reward_switch == 1) {
        [scrollView addSubview:rewardView];
        [rewardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.height.equalTo(scrollView);
            make.right.equalTo(scrollView);
        }];
//        monthlyPassView.hidden = YES;
    } else if (app.checkSettingModel.system_setting.monthly_ticket_switch == 1) {
        [scrollView addSubview:monthlyPassView];
        [monthlyPassView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.height.equalTo(scrollView);
            make.right.equalTo(scrollView);
        }];
//        rewardView.hidden = YES;
    }
    
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = [UIColor clearColor];
    [mainView addSubview:splitLine];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.1);
        make.left.right.bottom.equalTo(mainView);
        make.top.equalTo(scrollView.mas_bottom).priorityLow();
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setGiftNumBlock:(void (^)(NSInteger))giftNumBlock {
    _giftNumBlock = giftNumBlock;
    self.rewardView.giftNumBlock = giftNumBlock;
}

- (void)setTicketNumBlock:(void (^)(NSInteger))ticketNumBlock {
    _ticketNumBlock = ticketNumBlock;
    self.monthlyPassView.ticketNumBlock = ticketNumBlock;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 计算偏移量更新分页控件
    NSUInteger page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    self.pageTitleView.resetSelectedIndex = page;
}

- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * selectedIndex, 0) animated:YES];
}

- (void)setIsTicket:(BOOL)isTicket {
    if (isTicket) {
        if (self.titleArr.count > 1) {
            self.pageTitleView.resetSelectedIndex = 1;
            [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 1, 0) animated:NO];
        }
    } else {
        
        self.pageTitleView.resetSelectedIndex = 0;
        [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 0, 0) animated:NO];
    }
}

- (void)show {
    
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        [self.mainViewConstraint uninstall];
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.mainViewConstraint = make.top.equalTo(self.mas_bottom).offset(-CGRectGetHeight(self.mainView.frame));
        }];
        [self.mainView.superview layoutIfNeeded];
    }];
}

- (void)hide {
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        [self.mainViewConstraint uninstall];
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.mainViewConstraint = make.top.equalTo(self.mas_bottom);
        }];
        [self.mainView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

@end
