//
//  UIScrollView+Transition.h
//  WXReader
//
//  Created by Andrew on 2019/11/9.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (Transition)

- (void)addPullToRefresh:(UIView *)animater needConformNavBar:(BOOL)needConformNavBar block:(void (^)(void))block;

- (void)addInfiniteScrolling:(UIView *)animater needConformTabbar:(BOOL)needConformTabbar block:(void (^)(void))block;

- (void)show_RefreshFooter;

- (void)show_RefreshHeader;

- (void)hide_RefreshFooter;

- (void)hide_RefreshHeader;

- (void)end_Refreshing;

- (void)end_LoadingMore;

@end

NS_ASSUME_NONNULL_END
