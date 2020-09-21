//
//  WXYZ_GiftRewardView.m
//  WXReader
//
//  Created by LL on 2020/5/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_GiftRewardView.h"

#import "NSObject+Observer.h"
#import "WXYZ_GiftRewardModel.h"

#import "LLPageControl.h"
#import "WXYZ_AnnouncementView.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_RechargeViewController.h"

#import "WXYZ_GiftView.h"

@interface WXYZ_GiftRewardView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray<WXYZ_GiftRewardListModel *> *dataSourceArray;

@property (nonatomic, strong) WXYZ_GiftRewardModel *giftRewardModel;

@property (nonatomic, weak) UICollectionView *mainCollectionView;

@property (nonatomic, weak) LLPageControl *pageControl;

@property (nonatomic, weak) WXYZ_AnnouncementView *announcementView;

@property (nonatomic, weak) UILabel *remainLabel;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation WXYZ_GiftRewardView

- (instancetype)initWithBookModel:(WXYZ_ProductionModel *)bookModel {
    if (self = [super init]) {
        self.bookModel = bookModel;
        [self initialize];
        [self createSubviews];
        [self netRequest];
    }
    return self;
}

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:Notification_Login_Success object:nil];
}

- (void)createSubviews {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 2.0 * kMoreHalfMargin - 3 * kHalfMargin) / 4.0, 127.0);
    flowLayout.minimumInteritemSpacing = kHalfMargin;
    flowLayout.minimumLineSpacing = kHalfMargin;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.mainCollectionView = mainCollectionView;
    mainCollectionView.showsHorizontalScrollIndicator = NO;
    mainCollectionView.showsVerticalScrollIndicator = NO;
    mainCollectionView.backgroundColor = [UIColor clearColor];
    mainCollectionView.pagingEnabled = YES;
    mainCollectionView.dataSource = self;
    mainCollectionView.delegate = self;
    mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, kMoreHalfMargin);
    [mainCollectionView registerClass:WXYZ_GiftRewardCell.class forCellWithReuseIdentifier:@"Identifier"];
    [self addSubview:mainCollectionView];
    [mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(0);
        make.top.equalTo(self).offset(kMoreHalfMargin);
        make.height.mas_equalTo(127.0);
    }];
    
//    [mainCollectionView addObserver:KEY_PATH(mainCollectionView, contentSize) complete:^(UICollectionView * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
//        CGSize size = [newVal CGSizeValue];
//        [obj mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(size.height);
//        }];
//        [obj.superview setNeedsLayout];
//        [obj.superview layoutIfNeeded];
//    }];
    
    LLPageControl *pageControl = [LLPageControl pageControlWithRadius:3.5 spacing:6.0f numberOfPages:1];
    self.pageControl = pageControl;
    pageControl.currentPageIndicatorTintColor = kMainColor;
    pageControl.pageIndicatorTintColor = kColorRGB(225, 225, 225);
    [self addSubview:pageControl];
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainCollectionView.mas_bottom).offset(12.0);
        make.centerX.equalTo(self);
    }];
    
    WXYZ_AnnouncementView *announcementView = [[WXYZ_AnnouncementView alloc] init];
    self.announcementView = announcementView;
    announcementView.backgroundColor = kColorRGB(249, 248, 253);
    announcementView.layer.cornerRadius = 14.0f;
    announcementView.layer.masksToBounds = YES;
    announcementView.textFont = kFont11;
    announcementView.textColor = kGrayTextColor;
    announcementView.isCenter = YES;
    announcementView.duration = 5.0f;
    announcementView.userInteractionEnabled = NO;
    [self addSubview:announcementView];
    [announcementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pageControl.mas_bottom).offset(17.0f);
        make.left.equalTo(self).offset(kMoreHalfMargin);
        make.right.equalTo(self).offset(-kMoreHalfMargin);
        make.height.equalTo(announcementView.mas_width).multipliedBy(28.0 / 345.0);
    }];
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = kColorRGB(249, 248, 253);
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(announcementView.mas_bottom).offset(17.0f);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(65.0f);
    }];
    
    UILabel *remainLabel = [[UILabel alloc] init];
    self.remainLabel = remainLabel;
    remainLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:remainLabel];
    [remainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView).offset(kMoreHalfMargin);
        make.top.equalTo(bottomView.mas_top).offset(15.0);
    }];
    
    UIButton *rewardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rewardBtn.layer.cornerRadius = 19.0f;
    [rewardBtn setImage:[YYImage imageNamed:@"book_giftBtn"] forState:UIControlStateNormal];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rewardEvent)];
    [rewardBtn addGestureRecognizer:tap];
    [bottomView addSubview:rewardBtn];
    [rewardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView).offset(6.0);
        make.right.equalTo(bottomView).offset(-kMoreHalfMargin);
        make.size.mas_equalTo(CGSizeMake(105, 38));
    }];
    
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = [UIColor clearColor];
    [self addSubview:splitLine];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.1);
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(bottomView.mas_bottom).priorityLow();
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_GiftRewardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Identifier" forIndexPath:indexPath];
    [cell setGiftRewardModel:self.dataSourceArray[indexPath.row]];
    [cell setSelected:self.selectedIndex == indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [collectionView reloadData];
}

- (void)loginSuccess {
    NSString *prefix = @"余额：";
    NSString *remain = [NSString stringWithFormat:@"%zd", WXYZ_UserInfoManager.shareInstance.masterRemain];
    NSString *suffix = WXYZ_SystemInfoManager.masterUnit;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@", prefix, remain, suffix] attributes:@{NSForegroundColorAttributeName: kGrayTextColor, NSFontAttributeName: kFont14}];
    [str addAttribute:NSForegroundColorAttributeName value:kMainColor range:NSMakeRange(prefix.length, remain.length)];
    self.remainLabel.attributedText = str;
}

- (void)rewardEvent {
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    WXYZ_GiftRewardListModel *model = self.dataSourceArray[self.selectedIndex];
    NSDictionary *params = @{
        @"book_id" : @(self.bookModel.production_id),
        @"chapter_id" : @([WXYZ_ReaderBookManager sharedManager].chapter_id),
        @"gift_id" : @(model.gift_id)
    };
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Book_Reward_Gift_Send parameters:params model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"打赏成功"];
            NSString *text = [NSString stringWithFormat:@"%@", t_model[@"data"][@"reward_num"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeReward" object:text];
            !weakSelf.giftNumBlock ?: weakSelf.giftNumBlock([text integerValue]);
            [weakSelf.giftView hide];
        } else if (Compare_Json_isEqualTo(requestModel.code, 802)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@""];
            [[WXYZ_ViewHelper getCurrentNavigationController] pushViewController:[[WXYZ_RechargeViewController alloc] init] animated:YES];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 计算偏移量更新分页控件
    NSUInteger page = CGRectGetMinX(scrollView.bounds) / scrollView.contentOffset.x;
    if (scrollView.contentOffset.x == 0) {
        page = 0;
    }
    self.pageControl.currentPage = page;
}

- (void)netRequest {
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:Gift_List parameters:@{@"book_id":@(self.bookModel.production_id)} model:WXYZ_GiftRewardModel.class success:^(BOOL isSuccess, WXYZ_GiftRewardModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            weakSelf.giftRewardModel = t_model;
            weakSelf.dataSourceArray = t_model.list;
            weakSelf.pageControl.numberOfPages = ceil(weakSelf.dataSourceArray.count / 4.0);
            NSMutableArray<WXYZ_AnnouncementModel *> *arr = [NSMutableArray array];
            for (NSString *str in t_model.announce_list) {
                WXYZ_AnnouncementModel *tt_model = [[WXYZ_AnnouncementModel alloc] init];
                tt_model.content = @"";
                tt_model.title = str;
                [arr addObject:tt_model];
            }
            weakSelf.announcementView.modelArr = arr;
            NSString *prefix = @"余额：";
            NSString *remain = [NSString stringWithFormat:@"%zd", t_model.user.goldRemain];
            NSString *suffix = WXYZ_SystemInfoManager.masterUnit;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@ %@", prefix, remain, suffix] attributes:@{NSForegroundColorAttributeName: kGrayTextColor, NSFontAttributeName: kFont14}];
            [str addAttribute:NSForegroundColorAttributeName value:kMainColor range:NSMakeRange(prefix.length, remain.length)];
            weakSelf.remainLabel.attributedText = str;
            [weakSelf.mainCollectionView reloadData];
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

@end


@implementation WXYZ_GiftRewardCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    self.contentView.layer.cornerRadius = 2.5;
    self.contentView.layer.borderColor = kMainColor.CGColor;
    self.contentView.layer.borderWidth = 0.0f;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UILabel *flagLabel = [[UILabel alloc] init];
    flagLabel.font = kFont10;
    flagLabel.textColor = [UIColor whiteColor];
    flagLabel.backgroundColor = kColorRGB(255, 83, 81);
    flagLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.contentView.bounds) - kHalfMargin;
    flagLabel.textAlignment = NSTextAlignmentCenter;
    flagLabel.layer.cornerRadius = 2.0f;
    flagLabel.numberOfLines = 0;
    flagLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:flagLabel];
    [flagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
    }];
    
    UIImageView *coverImageView = [[UIImageView alloc] init];
    coverImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:coverImageView];
    [self.contentView sendSubviewToBack:coverImageView];
    [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(50.0, 50.0));
    }];
    
    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.textColor = kGrayTextColor;
    subtitle.font = kFont10;
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.numberOfLines = 0;
    subtitle.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:subtitle];
    [subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-kQuarterMargin);
        make.left.equalTo(self.contentView).offset(kQuarterMargin);
        make.right.equalTo(self.contentView).offset(-kQuarterMargin);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = kBlackColor;
    titleLabel.font = kFont13;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(subtitle.mas_top).offset(- kQuarterMargin);
        make.left.equalTo(self.contentView).offset(kQuarterMargin);
        make.right.equalTo(self.contentView).offset(-kQuarterMargin);
    }];
    
    [self addObserver:KEY_PATH(self, giftRewardModel) complete:^(WXYZ_GiftRewardCell * _Nonnull obj, id  _Nullable oldVal, WXYZ_GiftRewardListModel * _Nullable newVal) {
        flagLabel.text = newVal.flag ?: @"";
        CGFloat maxWidth = CGRectGetWidth(obj.contentView.bounds) - kHalfMargin;
        if (flagLabel.intrinsicContentSize.width + 12 < maxWidth) {
            maxWidth = flagLabel.intrinsicContentSize.width + 12;
        }
        [flagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(maxWidth);
            make.height.mas_equalTo(flagLabel.intrinsicContentSize.height + kQuarterMargin);
        }];
        flagLabel.hidden = newVal.flag.length == 0;
        [coverImageView setImageWithURL:[NSURL URLWithString:newVal.icon ?: @""] placeholder:HoldImage];
        titleLabel.text = newVal.title ?: @"";
        subtitle.text = newVal.gift_price ?: @"";
    }];
}

//- (UICollectionViewLayoutAttributes*)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes*)layoutAttributes {
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
//    CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
//    CGRect cellFrame = layoutAttributes.frame;
//    cellFrame.size.height = size.height;
//    layoutAttributes.frame = cellFrame;
//    return layoutAttributes;
//}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.contentView.layer.borderWidth = 1.0f;
    } else {
        self.contentView.layer.borderWidth = 0.0f;
    }
}

@end
