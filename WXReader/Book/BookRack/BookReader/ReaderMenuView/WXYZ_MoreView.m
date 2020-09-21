//
//  WXYZ_MoreView.m
//  WXReader
//
//  Created by LL on 2020/5/22.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_MoreView.h"

#import "UIView+LayoutCallback.h"
#import "NSObject+Observer.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_ProductionCollectionManager.h"

#import "WXYZ_BookMallDetailViewController.h"

#if WX_W_Share_Mode || WX_Q_Share_Mode
#import "WXYZ_ShareManager.h"
#endif

#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_BookMarkModel.h"

#import "WXYZ_BookReaderMenuBar.h"

@interface WXYZ_MoreCell : UICollectionViewCell

- (void)setDict:(NSDictionary <NSString *, NSString *> *)dict;

@end

typedef NS_ENUM(NSInteger, ReaderBookStyle) {
    ReaderBookDetail = 0,
    ReaderBookMark,
    ReaderBookRack,
    ReaderBookShare,
};

@interface WXYZ_MoreView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray<NSDictionary *> *moreDict;

@property (nonatomic, weak) UIView *mainView;

/// 背景视图
@property (nonatomic, weak) UIView *emptyView;

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@property (nonatomic, strong) WXYZ_ReaderBookManager *bookManager;

/// 书签状态
@property (nonatomic, assign) BOOL markStatus;

/// 书签Model
@property (nonatomic, strong) WXYZ_BookMarkModel *markModel;

/// 是不是封面
@property (nonatomic, assign) BOOL isCover;

@end

@implementation WXYZ_MoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
        [self createSubviews];
    }
    return self;
}

- (void)initialize {
    self.bookModel = [WXYZ_ReaderBookManager sharedManager].bookModel;
    self.bookManager = [WXYZ_ReaderBookManager sharedManager];
    
    // 章节内容
    NSString *chapterContent = [self.bookManager getChapterContent];
    // 页面内容
    NSString *pageContent = [self.bookManager getChapterDetailContent];
    
    NSRange range = [chapterContent rangeOfString:pageContent];
    
    if (self.isCover) {// 封面不能添加书签
        self.markStatus = NO;
    } else {
        // 获取当前章节所有的书签
        NSArray<WXYZ_BookMarkModel *> *markArr = [WXYZ_ProductionReadRecordManager bookMark:[WXYZ_UtilsHelper formatStringWithInteger:self.bookManager.book_id] chapterID:[WXYZ_UtilsHelper formatStringWithInteger:self.bookManager.chapter_id]];
        for (WXYZ_BookMarkModel *t_model in markArr) {
            if (t_model.specificIndex >= range.location && t_model.specificIndex < (range.location + range.length)) {
                self.markModel = t_model;
                self.markStatus = YES;
                break;
            }
        }
    }
}

- (void)createSubviews {
    self.backgroundColor = kBlackTransparentColor;
    [kMainWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(kMainWindow);
    }];
    
    UIView *emptyView = [[UIView alloc] init];
    self.emptyView = emptyView;
    emptyView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [emptyView addGestureRecognizer:tap];
    [self addSubview:emptyView];
    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.top.equalTo(self.mas_bottom);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(100 + 25 + 25 + PUB_TABBAR_HEIGHT);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.estimatedItemSize = CGSizeMake(62.0, 60.0f);
    CGFloat spacing = (SCREEN_WIDTH - (2 * kMargin) - (self.moreDict.count * flowLayout.estimatedItemSize.width)) / (self.moreDict.count - 1);
    spacing = spacing < kMargin ? kMargin : spacing;
    flowLayout.minimumInteritemSpacing = spacing;
    flowLayout.minimumLineSpacing = kMargin;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[WXYZ_MoreCell class] forCellWithReuseIdentifier:@"Identifier"];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [mainView addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainView).offset(25);
        make.left.equalTo(mainView).offset(kMargin);
        make.right.equalTo(mainView).offset(- kMargin);
        make.height.mas_equalTo(100);
    }];
    [collectionView addObserver:KEY_PATH(collectionView, contentSize) complete:^(UICollectionView * _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
        CGSize size = [newVal CGSizeValue];
        [obj mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(size.height);
        }];
    }];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [closeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET / 2, 0)];
    closeButton.titleLabel.font = kFont16;
    [mainView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(PUB_TABBAR_HEIGHT);
        make.left.width.equalTo(mainView);
        make.top.equalTo(collectionView.mas_bottom).offset(25.0f);
    }];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [closeButton addGestureRecognizer:tap];
    
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = kGrayLineColor;
    [mainView addSubview:splitLine];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.width.top.equalTo(closeButton);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)show {
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(- CGRectGetHeight(self.mainView.frame));
        }];
        [self.mainView.superview layoutIfNeeded];
    }];
}

- (void)hide {
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        [self.mainView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            [[WXYZ_BookReaderMenuBar sharedManager] hiddend];
        }
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint emptyPoint = [self convertPoint:point toView:self.mainView];
    if ([self.mainView pointInside:emptyPoint withEvent:event]) {
        return [super hitTest:point withEvent:event];
    } else {
        return self.emptyView;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.moreDict.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_MoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Identifier" forIndexPath:indexPath];
    [cell setDict:self.moreDict[indexPath.row].allValues.firstObject];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.moreDict[indexPath.row];
    ReaderBookStyle style = [dict.allKeys.firstObject integerValue];
    
    switch (style) {
        case ReaderBookDetail:
        {
            [self hide];
                        
            UINavigationController *nav = [WXYZ_ViewHelper getCurrentNavigationController];
            if (nav.viewControllers.count > 1) {
                UIViewController *tmp = nav.viewControllers[nav.viewControllers.count - 2];
                if ([tmp isKindOfClass:WXYZ_BookMallDetailViewController.class]) {
                    [nav popViewControllerAnimated:YES];
                    return;
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Push object:@"WXYZ_BookMallDetailViewController"];
        }
            break;
        case ReaderBookMark:
        {
            if (self.isCover) {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前页不支持加书签"];
                return;
            }
            
            NSString *pageContent = [self.bookManager getChapterDetailContent];
            if ([pageContent isEqualToString:@"\uFFFC"]) {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"当前页不支持加书签"];
                return;
            }
            
            NSDictionary *dict = nil;
            if (self.markStatus) {
                // 移除书签
                [WXYZ_ProductionReadRecordManager removeBookMark:self.markModel];
                dict = @{@(ReaderBookMark) : @{@"添加书签" : @"book_add_mark"}};
                self.markStatus = NO;
            } else {
                // 添加书签
                self.markModel = [WXYZ_ProductionReadRecordManager addBookMark:[WXYZ_UtilsHelper formatStringWithInteger:self.bookManager.book_id] chapterID:[WXYZ_UtilsHelper formatStringWithInteger:self.bookManager.chapter_id] chapterSort:self.bookManager.currentChapterIndex chapterTitle:[self.bookManager getChapterTitle] chapterContent:[self.bookManager getChapterContent] pageContent:pageContent];
                dict = @{@(ReaderBookMark) : @{@"取消书签" : @"book_remove_mark"}};
                self.markStatus = YES;
            }
            NSMutableArray<NSDictionary *> *arr = [NSMutableArray arrayWithArray:self.moreDict];
            [arr replaceObjectAtIndex:indexPath.row withObject:dict];
            self.moreDict = [arr copy];
            [collectionView reloadData];
        }
            break;
        case ReaderBookRack:
        {
            if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel]) break;
            if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] addCollectionWithProductionModel:self.bookModel atIndex:0]) {
                
                [WXYZ_UtilsHelper synchronizationRackProductionWithProduction_id:self.bookModel.production_id productionType:WXYZ_ProductionTypeBook complete:nil];
                
                NSDictionary *dict = @{@(ReaderBookRack) : @{@"已收藏" : @"book_remove_rack"}};
                NSMutableArray<NSDictionary *> *arr = [NSMutableArray arrayWithArray:self.moreDict];
                [arr replaceObjectAtIndex:indexPath.row withObject:dict];
                self.moreDict = [arr copy];
                [collectionView reloadData];
            } else {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"添加失败"];
            }
        }
            break;
        case ReaderBookShare:
        {
            [self hide];
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Hidden_ToolNav object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Hidden_Bottom_ToolNav object:nil];
#if WX_W_Share_Mode || WX_Q_Share_Mode
            [[WXYZ_ShareManager sharedManager] shareProductionWithChapter_id:self.bookManager.chapter_id controller:[WXYZ_ViewHelper getWindowRootController] type:WXYZ_ShareProductionBook shareState:WXYZ_ShareStateAll production_id:self.bookModel.production_id complete:^{}];
#endif
        }
            break;
            
        default:
            break;
    };
}

- (NSArray<NSDictionary *> *)moreDict {
    if (!_moreDict) {
        NSMutableArray<NSDictionary *> *arr = [NSMutableArray array];
                
        [arr addObject:@{@(ReaderBookDetail) : @{@"书籍详情" : @"book_detail"}}];
        if (self.markStatus) {
            [arr addObject:@{@(ReaderBookMark) : @{@"取消书签" : @"book_remove_mark"}}];
        } else {
            [arr addObject:@{@(ReaderBookMark) : @{@"添加书签" : @"book_add_mark"}}];
        }
        
        if ([[WXYZ_ProductionCollectionManager shareManagerWithProductionType:WXYZ_ProductionTypeBook] isCollectedWithProductionModel:self.bookModel]) {
            [arr addObject:@{@(ReaderBookRack) : @{@"已收藏" : @"book_remove_rack"}}];
        } else {
            [arr addObject:@{@(ReaderBookRack) : @{@"收藏" : @"book_add_rack"}}];
        }
#if WX_Q_Share_Mode || WX_W_Share_Mode
        [arr addObject:@{@(ReaderBookShare) : @{@"分享" : @"book_share"}}];
#endif
        _moreDict = [arr copy];
    }
    
    return _moreDict;
}

- (BOOL)isCover {
    return self.bookManager.currentChapterIndex == 0 && self.bookManager.currentPagerIndex == 0;
}

@end


@implementation WXYZ_MoreCell {
    UIImageView *_coverImageView;
    UILabel *_titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    _coverImageView.userInteractionEnabled = NO;
    _coverImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_coverImageView];
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.equalTo(self.contentView);
        make.height.equalTo(_coverImageView.mas_width);
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = kBlackColor;
    _titleLabel.font = kFont14;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverImageView.mas_bottom).offset(14.0f);
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).priorityLow();
    }];
}

- (void)setDict:(NSDictionary <NSString *, NSString *> *)dict {
    _coverImageView.image = [YYImage imageNamed:dict.allValues.firstObject];
    _titleLabel.text = dict.allKeys.firstObject ?: @"";
}

- (UICollectionViewLayoutAttributes*)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes*)layoutAttributes {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
    CGRect cellFrame = layoutAttributes.frame;
    cellFrame.size.height = size.height;
    layoutAttributes.frame = cellFrame;
    return layoutAttributes;
}

@end
