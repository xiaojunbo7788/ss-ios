//
//  WXYZ_LoadMoreFooter.m
//  WXReader
//
//  Created by Andrew on 2019/11/11.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_LoadMoreFooter.h"
#import "WXYZ_ComicMenuBottomBar.h"

@interface WXYZ_LoadMoreFooter ()

@property (weak, nonatomic) UILabel *footerToastLabel;

@end

@implementation WXYZ_LoadMoreFooter

- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 50;
    
    // 添加label
    UILabel *label = [[UILabel alloc] init];
    label.textColor = kBlackColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = kFont12;
    [self addSubview:label];
    
    self.footerToastLabel = label;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.footerToastLabel.frame = CGRectMake(0, - (PUB_TABBAR_HEIGHT + Comic_Menu_Bottom_Bar_Top_Height) + 30, SCREEN_WIDTH, 20);
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
            self.footerToastLabel.text = @"上拉加载下一篇";
            break;
        case MJRefreshStateRefreshing:
            self.footerToastLabel.text = @"正在加载下一篇";
            break;
        case MJRefreshStatePulling:
            self.footerToastLabel.text = @"松开加载下一篇";
            break;
        case MJRefreshStateNoMoreData:
            self.footerToastLabel.text = @"没有下一章了";
            break;
        default:
            break;
    }
}

@end
