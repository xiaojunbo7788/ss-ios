//
//  WXYZ_DirectoryViewController.m
//  WXReader
//
//  Created by LL on 2020/5/23.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_DirectoryViewController.h"

#import "WXYZ_BookDirectoryViewController.h"
#import "WXYZ_BookMarkViewController.h"

@interface WXYZ_DirectoryViewController ()<SGPageContentCollectionViewDelegate, SGPageTitleViewDelegate>

@property (nonatomic, strong) SGPageTitleView *pageTitleView;
@property (nonatomic, strong) SGPageContentCollectionView *pageContentCollectionView;

@property (nonatomic, weak) WXYZ_BookDirectoryViewController *bookDir;

@property (nonatomic, weak) UIButton *rightButton;

@end

@implementation WXYZ_DirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setStatusBarDefaultStyle];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
}

- (void)initialize {
    [self setNavigationBarTitle:@""];
    [self hiddenSeparator];
    
    [self setNavigationBarRightButton:({
        UIButton *rightBtn = [[UIButton alloc] init];
        self.rightButton = rightBtn;
        rightBtn.backgroundColor = [UIColor clearColor];
        rightBtn.adjustsImageWhenHighlighted = NO;
        [rightBtn setImage:[YYImage imageNamed:@"book_directory_order"] forState:UIControlStateNormal];
        [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        [rightBtn addTarget:self action:@selector(orderChapter:) forControlEvents:UIControlEventTouchUpInside];
        rightBtn;
    })];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navigationBar.navTitleLabel);
        make.right.equalTo(self.view).offset(-kMargin);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
}

- (void)createSubviews {
    WXYZ_BookDirectoryViewController *bookDir = [[WXYZ_BookDirectoryViewController alloc] init];
    bookDir.isReader = self.isReader;
    self.bookDir = bookDir;
    if (self.bookModel) {
        bookDir.bookModel = self.bookModel;
    } else {
        bookDir.book_id = self.book_id;
    }
    bookDir.isBookDetailPush = self.isBookDetailPush;
    [self addChildViewController:bookDir];
    
    WXYZ_BookMarkViewController *bookMark = [[WXYZ_BookMarkViewController alloc] init];
    bookMark.isReader = self.isReader;
    bookMark.bookModel = self.bookModel;
    [self addChildViewController:bookMark];
    
    self.pageConfigure.indicatorColor = kMainColor;
    self.pageConfigure.indicatorStyle = SGIndicatorStyleDynamic;
    self.pageConfigure.indicatorHeight = 3;
    self.pageConfigure.needBounces = NO;
    self.pageConfigure.indicatorFixedWidth = 10;
    self.pageConfigure.indicatorDynamicWidth = 14;
    self.pageConfigure.indicatorToBottomDistance = 3;
    self.pageConfigure.titleSelectedColor = kBlackColor;
    self.pageConfigure.titleSelectedFont = kFont18;
    self.pageConfigure.titleFont = kFont16;
    self.pageConfigure.titleColor = kBlackColor;
    self.pageContentCollectionView = [[SGPageContentCollectionView alloc] initWithFrame:CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT) parentVC:self childVCs:@[bookDir, bookMark]];
    _pageContentCollectionView.delegatePageContentCollectionView = self;
    [self.view addSubview:self.pageContentCollectionView];
    
    self.pageTitleView = [SGPageTitleView pageTitleViewWithFrame:CGRectMake((SCREEN_WIDTH - 120.0f) / 2.0f, PUB_NAVBAR_OFFSET + kMargin, 120.0f, self.pageViewHeight) delegate:self titleNames:@[@"目录", @"书签"] configure:self.pageConfigure];
    self.pageTitleView.backgroundColor = kWhiteColor;
    [self.navigationBar addSubview:self.pageTitleView];
}
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    [self.pageContentCollectionView setPageContentCollectionViewCurrentIndex:selectedIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex
{
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

- (void)pageContentCollectionView:(SGPageContentCollectionView *)pageContentCollectionView index:(NSInteger)index {
    self.rightButton.hidden = index != 0;
}

- (void)orderChapter:(UIButton *)sender {
    [self.bookDir orderChapter:sender];
}

@end
