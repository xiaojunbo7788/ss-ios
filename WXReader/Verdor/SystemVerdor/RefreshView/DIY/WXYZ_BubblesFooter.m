//
//  WXYZ_BubblesFooter.m
//  demo
//
//  Created by Andrew on 2019/11/9.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BubblesFooter.h"
#import "WXYZ_LoadingBubbles.h"

@interface WXYZ_BubblesFooter ()

@property (strong, nonatomic) WXYZ_LoadingBubbles *loadingPanel;

@end

@implementation WXYZ_BubblesFooter

- (void)prepare
{
    [super prepare];
    
    WXYZ_LoadingBubbles *loadingPanel = [[WXYZ_LoadingBubbles alloc] init];
    loadingPanel.backgroundColor = [UIColor clearColor];
    loadingPanel.isHeader = NO;
    [self addSubview:loadingPanel];
    self.loadingPanel = loadingPanel;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];

    // 设置控件的高度
    self.mj_h = 40;
    if (self.adaptX) {
        self.mj_h = 40 + PUB_TABBAR_OFFSET;
    }
    self.ignoredScrollViewContentInsetBottom = - PUB_TABBAR_OFFSET;
    
    _loadingPanel.frame = CGRectMake(0, 0, 40, 10);
    _loadingPanel.center = CGPointMake(self.center.x, 20);
}

#pragma mark 监听scrollView的contentOffset改变
- (CGFloat)happenOffsetY
{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginalInset.top;
    } else {
        return - self.scrollViewOriginalInset.top;
    }
}
- (CGFloat)heightForContentBreakView
{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
    return self.scrollView.contentSize.height - h;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
    // 如果正在刷新，直接返回
    if (self.state == MJRefreshStateRefreshing) return;
    
    _scrollViewOriginalInset = self.scrollView.mj_inset;
    
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.mj_offsetY;
    // 尾部控件刚好出现的offsetY
    CGFloat happenOffsetY = [self happenOffsetY];
    // 如果是向下滚动到看不见尾部控件，直接返回
    if (currentOffsetY <= happenOffsetY) return;
    
    CGFloat pullingPercent = (currentOffsetY - happenOffsetY) / self.mj_h;
    
    // 如果已全部加载，仅设置pullingPercent，然后返回
    if (self.state == MJRefreshStateNoMoreData) {
        self.pullingPercent = pullingPercent;
        return;
    }
    
    if (self.scrollView.isDragging) {
        self.pullingPercent = pullingPercent;
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY + self.mj_h;
        
        if (self.state == MJRefreshStateIdle && currentOffsetY > normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && currentOffsetY <= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = MJRefreshStateIdle;
        }
    } else if (self.state == MJRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        [self beginRefreshing];
    } else if (pullingPercent < 1) {
        self.pullingPercent = pullingPercent;
    }
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];

}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;

    switch (state) {
        case MJRefreshStateIdle:
            [self.loadingPanel stopPageLoadingAnimation];
            break;
        case MJRefreshStateRefreshing:
            [self.loadingPanel doPageLoadingAnimation];
            break;
        case MJRefreshStateNoMoreData:
            [self.loadingPanel stopPageLoadingAnimation];
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    if (self.state == MJRefreshStateNoMoreData) {
        return;
    }
    [super setPullingPercent:pullingPercent];
    
    self.loadingPanel.pullingPercent = pullingPercent;
}

@end
