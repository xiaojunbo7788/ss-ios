//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  UIScrollView+MJRefresh.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "UIScrollView+MJRefresh.h"
#import "MJRefreshHeader.h"
#import "MJRefreshFooter.h"
#import "WXYZ_BubblesHeader.h"
#import "WXYZ_BubblesFooter.h"
#import "WXYZ_LoadMoreFooter.h"
#import <objc/runtime.h>

@implementation UIScrollView (MJRefresh)

#pragma mark - header
static const char MJRefreshHeaderKey = '\0';
- (void)setMj_header:(MJRefreshHeader *)mj_header
{
    if (mj_header != self.mj_header) {
        // 删除旧的，添加新的
        [self.mj_header removeFromSuperview];
        [self insertSubview:mj_header atIndex:0];
        
        // 存储新的
        objc_setAssociatedObject(self, &MJRefreshHeaderKey,
                                 mj_header, OBJC_ASSOCIATION_RETAIN);
    }
}

- (MJRefreshHeader *)mj_header
{
    return objc_getAssociatedObject(self, &MJRefreshHeaderKey);
}

#pragma mark - footer
static const char MJRefreshFooterKey = '\0';
- (void)setMj_footer:(MJRefreshFooter *)mj_footer
{
    if (mj_footer != self.mj_footer) {
        // 删除旧的，添加新的
        [self.mj_footer removeFromSuperview];
        [self insertSubview:mj_footer atIndex:0];
        
        // 存储新的
        objc_setAssociatedObject(self, &MJRefreshFooterKey,
                                 mj_footer, OBJC_ASSOCIATION_RETAIN);
    }
}

- (MJRefreshFooter *)mj_footer
{
    return objc_getAssociatedObject(self, &MJRefreshFooterKey);
}

- (UILabel *)titleLabel {
    return _titleLabel;
}

#pragma mark - 过期
- (void)setFooter:(MJRefreshFooter *)footer
{
    self.mj_footer = footer;
}

- (MJRefreshFooter *)footer
{
    return self.mj_footer;
}

- (void)setHeader:(MJRefreshHeader *)header
{
    self.mj_header = header;
}

- (MJRefreshHeader *)header
{
    return self.mj_header;
}

#pragma mark - other
- (NSInteger)mj_totalDataCount
{
    NSInteger totalCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;

        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;

        for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

- (void)addHeaderRefreshWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshBlock
{
    __weak typeof(self) weakSelf = self;
    WXYZ_BubblesHeader *header = [WXYZ_BubblesHeader headerWithRefreshingBlock:^{
        weakSelf.mj_footer.state = MJRefreshStateIdle;
        _titleLabel.hidden = YES;
        if (refreshBlock) {
            refreshBlock();
        }
    }];
    header.adaptX = NO;
    self.mj_header = header;
}

- (void)addHigherHeaderRefreshWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshBlock
{
    WXYZ_BubblesHeader *header = [WXYZ_BubblesHeader headerWithRefreshingBlock:^{
        if (refreshBlock) {
            refreshBlock();
        }
    }];
    header.adaptX = YES;
    self.mj_header = header;
}

static UILabel *_titleLabel;
- (void)addFooterRefreshWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshBlock
{
    WXYZ_BubblesFooter *footer = [WXYZ_BubblesFooter footerWithRefreshingBlock:^{
        if (refreshBlock) {
            refreshBlock();
        }
    }];
    footer.adaptX = NO;
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.textColor = kGrayTextColor;
    titleLabel.text = @"没有更多了";
    titleLabel.font = kFont12;
    [footer addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(footer);
    }];
    titleLabel.hidden = YES;
    self.mj_footer = footer;
}

- (void)addHigherFooterRefreshWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshBlock
{
    WXYZ_BubblesFooter *footer = [WXYZ_BubblesFooter footerWithRefreshingBlock:^{
        if (refreshBlock) {
            refreshBlock();
        }
    }];
    footer.adaptX = YES;
    self.mj_footer = footer;
}

- (void)addToastFooterRefreshWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshBlock
{
    WXYZ_LoadMoreFooter *footer = [WXYZ_LoadMoreFooter footerWithRefreshingBlock:^{
        if (refreshBlock) {
            refreshBlock();
        }
    }];
    self.mj_footer = footer;
}

- (void)showRefreshHeader
{
    if (self.mj_header.hidden) {
        self.mj_header.hidden = NO;
    }
}

- (void)showRefreshFooter
{
    if (self.mj_footer.hidden) {
        self.mj_footer.hidden = NO;
    }
    _titleLabel.hidden = YES;
    self.mj_footer.state = MJRefreshStateIdle;
}

- (void)hideRefreshHeader
{
    if (!self.mj_header.hidden) {
        self.mj_header.hidden = YES;
    }
}

- (void)hideRefreshFooter
{
    _titleLabel.hidden = NO;
    [self.mj_footer endRefreshingWithNoMoreData];
    self.mj_footer.state = MJRefreshStateNoMoreData;
    
}

- (void)endRefreshing
{
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

@end
