//
//  LLPageControl.m
//  iOSHelper
//
//  Created by LL on 2020/5/3.
//  Copyright © 2020 Chair. All rights reserved.
//

#import "LLPageControl.h"

@implementation LLPageControl

#pragma mark - Public
+ (instancetype)pageControlWithRadius:(CGFloat)radius spacing:(CGFloat)spacing numberOfPages:(NSUInteger)numberOfPages {
    LLPageControl *page = [[self alloc] init];
    if (page) {
        page.radius = radius;
        page.spacing = spacing;
        page.numberOfPages = numberOfPages;
    }
    return page;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}


#pragma mark - Private
- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - 创建小圆并添加约束
- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    // 添加指定数量的小圆
    NSMutableArray<UIView *> *array = [NSMutableArray array];
    for (NSInteger i = 0; i < self.numberOfPages; i++) {
        UIView *view = [[UIView alloc] init];
        view.tag = 10000 + i;
        if (i == self.currentPage) {
            view.backgroundColor = self.currentPageIndicatorTintColor;
        } else {
            view.backgroundColor = self.pageIndicatorTintColor;
        }
        view.layer.cornerRadius = self.radius;
        view.layer.masksToBounds = YES;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)]];
        [self addSubview:view];
        [array addObject:view];
    }
    
    // 添加约束
    UIView *_view;
    for (UIView *view in array) {
        if (!_view) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
        } else {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_view attribute:NSLayoutAttributeRight multiplier:1.0f constant:self.spacing]];
        }
        _view = view;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.0f constant:self.radius * 2.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.0f constant:self.radius * 2.0]];
    }
}

- (CGSize)intrinsicContentSize {
    CGFloat width = self.numberOfPages * (self.radius * 2.0) + (self.numberOfPages - 1) * self.spacing;
    return CGSizeMake(width, self.radius * 2.0);
}

- (void)click:(UIView *)view {
    !self.clickBlock ?: self.clickBlock(self, view.tag - 10000);
}


#pragma mark - Setter
- (void)setCurrentPage:(NSUInteger)currentPage {
    UIView *view = [self viewWithTag:10000 + _currentPage];
    view.backgroundColor = self.pageIndicatorTintColor;
    _currentPage = currentPage;
    view = [self viewWithTag:10000 + _currentPage];
    view.backgroundColor = self.currentPageIndicatorTintColor;
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark Getter
- (UIColor *)pageIndicatorTintColor {
    return _pageIndicatorTintColor = _pageIndicatorTintColor ?: [UIColor whiteColor];
}

- (UIColor *)currentPageIndicatorTintColor {
    return _currentPageIndicatorTintColor = _currentPageIndicatorTintColor ?: [UIColor orangeColor];
}

@end
