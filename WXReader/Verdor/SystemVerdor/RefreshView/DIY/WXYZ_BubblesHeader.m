//
//  WXYZ_BubblesHeader.m
//  WXReader
//
//  Created by Andrew on 2019/11/9.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_BubblesHeader.h"
#import "WXYZ_LoadingBubbles.h"

@interface WXYZ_BubblesHeader ()

@property (strong, nonatomic) WXYZ_LoadingBubbles *loadingPanel;

@end

@implementation WXYZ_BubblesHeader

- (void)prepare
{
    [super prepare];
    
    WXYZ_LoadingBubbles *loadingPanel = [[WXYZ_LoadingBubbles alloc] init];
    loadingPanel.backgroundColor = [UIColor clearColor];
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
        self.mj_h = 40 + PUB_NAVBAR_OFFSET;
    }
    
    _loadingPanel.frame = CGRectMake(self.center.x - 20, self.mj_h - 20, 40, 10);
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
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
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
    self.loadingPanel.pullingPercent = pullingPercent;
}

@end
