//
//  UIScrollView+Transition.m
//  WXReader
//
//  Created by Andrew on 2019/11/9.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "UIScrollView+Transition.h"
#import "WXYZ_BubblesHeader.h"
#import "WXYZ_BubblesFooter.h"

@implementation UIScrollView (Transition)

- (void)addPullToRefresh:(UIView *)animater needConformNavBar:(BOOL)needConformNavBar block:(void (^)(void))block
{
    WXYZ_BubblesHeader *header = [WXYZ_BubblesHeader headerWithRefreshingBlock:^{
        if (block) {
            block();
        }
    }];
    header.adaptX = needConformNavBar;
    self.mj_header = header;
}

- (void)addInfiniteScrolling:(UIView *)animater needConformTabbar:(BOOL)needConformTabbar block:(void (^)(void))block
{
    WXYZ_BubblesFooter *footer = [WXYZ_BubblesFooter footerWithRefreshingBlock:^{
        if (block) {
            block();
        }
    }];
    footer.adaptX = needConformTabbar;
    self.mj_footer = footer;
}

- (void)show_RefreshFooter
{
    if (self.mj_footer.hidden) {
        self.mj_footer.hidden = NO;
    }
}

- (void)show_RefreshHeader
{
    if (self.mj_header.hidden) {
        self.mj_header.hidden = NO;
    }
}

- (void)hide_RefreshFooter
{
//    if (!self.mj_footer.hidden) {
//        self.mj_footer.hidden = YES;
//    }
    [self.mj_footer endRefreshingWithNoMoreData];
    self.mj_footer.state = MJRefreshStateNoMoreData;
}

- (void)hide_RefreshHeader
{
    if (!self.mj_header.hidden) {
        self.mj_header.hidden = YES;
    }
}

- (void)end_Refreshing
{
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

- (void)end_LoadingMore
{
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

@end
