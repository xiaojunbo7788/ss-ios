//
//  DPPagerViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/22.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_ScorllPageViewController.h"
#import "WXYZ_ReaderBookManager.h"

#define AnimateDuration 0.2

@interface WXYZ_ScorllPageViewController ()

/*! 左拉右拉手势 */
@property(nonatomic, strong) UIPanGestureRecognizer *pan;

/*! 点击手势 */
@property(nonatomic, strong) UITapGestureRecognizer *tap;

/*! 手势触发点在左边 辨认方向 左边拿上一个控制器  右边拿下一个控制器 */
@property(nonatomic) BOOL isLeft;

/*! 判断执行pan手势 */
@property(nonatomic) BOOL isPan;

/*! 手势是否重新开始识别 */
@property(nonatomic) BOOL isPanBegin;

@property(nonatomic) BOOL isAnimating;

@property (nonatomic, assign) BOOL haveNextPager;

/*! 临时View 通过代理获取回来的View 还没有完全展示出来的View */
@property(nonatomic, strong, nullable) UIView *tempView;

@property(nonatomic) NSInteger numberOfPages;

@property(nonatomic) NSInteger currentIndex;

@property(nonatomic, readonly) NSInteger lastIndex;

@property(nonatomic, readonly) NSInteger nextIndex;

/*! 内部切换控制 能否切换到上一页 */
@property(nonatomic) BOOL scrollToLastEnabled;
/*! 内部切换控制 能否切换到下一页 */
@property(nonatomic) BOOL scrollToNextEnabled;

@end

@implementation WXYZ_ScorllPageViewController

- (void)dealloc {
    // 移除手势
    [self.view removeGestureRecognizer:self.pan];
    [self.view removeGestureRecognizer:self.tap];
    
    if (self.currentView) {
        [self.currentView removeFromSuperview];
        _currentView = nil;
    }
    
    if (self.tempView) {
        [self.tempView removeFromSuperview];
        self.tempView = nil;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.switchAnimated = YES;
        
        self.haveNextPager = [[WXYZ_ReaderBookManager sharedManager] haveNextPager];
        
        self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        
        self.switchSlideEnabled = YES;
        self.switchTapEnabled = YES;
        
        self.switchToLastEnabled = YES;
        self.switchToNextEnabled = YES;
        
        self.circleSwitchEnabled = YES;
        self.scrollToLastEnabled = YES;
        self.scrollToNextEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.masksToBounds = YES;
    
    [self.view removeGestureRecognizer:self.tap];
    [self.view removeGestureRecognizer:self.pan];
    [self.view addGestureRecognizer:self.pan];
    [self.view addGestureRecognizer:self.tap];
}

#pragma mark - GestureRecognizerHandle
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGPoint tempPoint = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        if (self.isAnimating) return;
        self.isAnimating = YES;
        self.isPan = YES;
        self.isPanBegin = YES;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if (self.isPanBegin) {
            self.isPanBegin = NO;
            
            self.isLeft = tempPoint.x > 0 ? YES: NO;
            
            if (![self canHandlePanOrTap]) {
                self.isPan = NO;
                return;
            }
            
            self.tempView = [self getNeedsView];
            [self addView:self.tempView];
        }
        
        if (!self.isPan) return;
        
        
        if (!self.tempView) return;
        
        if (self.switchAnimated) {
            if (self.isLeft) {
                [self.view bringSubviewToFront:self.currentView];
                self.tempView.frame = CGRectMake( - self.view.width + tempPoint.x, 0, self.view.width, self.view.height);
                self.currentView.frame = CGRectMake(tempPoint.x, 0, self.view.width, self.view.height);
                
            } else if (self.haveNextPager) {
                self.currentView.frame = CGRectMake(tempPoint.x > 0 ? 0 : tempPoint.x, 0, self.view.width, self.view.height);
                self.tempView.frame = CGRectMake(self.view.width + tempPoint.x, 0, self.view.width, self.view.height);
            }
        }
    } else { //!< 手势结束
        if (!self.isPan) return;
        
        self.isPan = NO;
        
        if (!self.tempView) {
            self.isAnimating = NO;
            return;
        }
        BOOL isSuccess = YES;
        
        if (self.switchAnimated) {
            if (self.isLeft) {
                
                if (self.tempView.frame.origin.x <= -(self.view.width - self.view.width*0.18)) {
                    isSuccess = NO;
                }
                
            } else {
                if (self.currentView.frame.origin.x >= -self.view.width*0.18) {
                    isSuccess = NO;
                }
            }
        }
        // 手势结束
        [self GestureSuccess:isSuccess animated:self.switchAnimated];
        
    }
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    // 正在动画
    if (self.isAnimating) return;
    
    self.isAnimating = YES;
    
    CGPoint touchPoint = [recognizer locationInView:self.view];
    
    self.isLeft = touchPoint.x < self.view.centerX ? YES: NO;
    
    if (![self canHandlePanOrTap]) {
        return;
    }
    
    self.tempView = [self getNeedsView];
    if (self.tempView == nil) return;
    [self addView:self.tempView];
    
    WS(weakSelf)
    if (self.isLeft) { // 左边
        [self.view bringSubviewToFront:self.currentView];
        self.tempView.frame = CGRectMake(- self.view.width, 0, self.view.width, self.view.height);
        [UIView animateWithDuration:AnimateDuration animations:^{
            weakSelf.tempView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
            weakSelf.currentView.frame = CGRectMake(self.view.width, 0, self.view.width, self.view.height);
            
        } completion:^(BOOL finished) {
            [weakSelf animateSuccess:YES];
        }];
    } else {
        if (self.haveNextPager) {
            self.tempView.frame = CGRectMake(self.view.width, 0, self.view.width, self.view.height);
            [UIView animateWithDuration:AnimateDuration animations:^{
                weakSelf.currentView.frame = CGRectMake(- self.view.width, 0, self.view.width, self.view.height);
                weakSelf.tempView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
            } completion:^(BOOL finished) {
                [weakSelf animateSuccess:YES];
            }];
        } else {
            self.isAnimating = NO;
        }
        
    }
    self.haveNextPager = [[WXYZ_ReaderBookManager sharedManager] haveNextPager];
    
}


- (BOOL)canHandlePanOrTap {
    
    BOOL can = YES;
    if (!self.numberOfPages) {
        self.isAnimating = NO;
        return NO;
    }
    if (self.isLeft) {
        if (!self.switchToLastEnabled || !self.scrollToLastEnabled) {
            self.isAnimating = NO;
            can = NO;
            if ([self.delegate respondsToSelector:@selector(dp_pageControllerSwitchToLastDisabled:)]) {
                [self.delegate dp_pageControllerSwitchToLastDisabled:self];
            }
        }
    } else {
        if (!self.switchToNextEnabled || !self.scrollToNextEnabled) {
            self.isAnimating = NO;
            can = NO;
            if ([self.delegate respondsToSelector:@selector(dp_pageControllerSwitchToNextDisabled:)]) {
                [self.delegate dp_pageControllerSwitchToNextDisabled:self];
            }
        }
    }
    
    return can;
}

- (UIView *)getNeedsView {
    UIView *view = nil;
    
    if (![self.dataSource respondsToSelector:@selector(dp_pageController:viewForIndex:direction:)]) {
        self.isAnimating = NO;
        return view;
    }
    
    if (self.isLeft) {
        view = [self.dataSource dp_pageController:self viewForIndex:self.lastIndex direction:DPPageRollingDirectionLeft];
    } else {
        view = [self.dataSource dp_pageController:self viewForIndex:self.nextIndex direction:DPPageRollingDirectionRight];
    }
    
    if (!view) {
        self.isAnimating = NO;
    }
    
    return view;
}

/**
 *  手势结束
 */
- (void)GestureSuccess:(BOOL)isSuccess animated:(BOOL)animated
{    
    if (self.tempView) {
        
        if (self.isLeft) { // 左边
            
            if (animated) {
                __weak WXYZ_ScorllPageViewController *weakSelf = self;
                
                [UIView animateWithDuration:AnimateDuration animations:^{
                    
                    if (isSuccess) {
                        
                        weakSelf.tempView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                        weakSelf.currentView.frame = CGRectMake(self.view.width, 0, self.view.width, self.view.height);
                        
                    } else {
                        
                        weakSelf.tempView.frame = CGRectMake(-self.view.width, 0, self.view.width, self.view.height);
                        weakSelf.currentView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                    }
                    
                } completion:^(BOOL finished) {
                    
                    [weakSelf animateSuccess:isSuccess];
                }];
                
            } else  {
                
                if (isSuccess) {
                    
                    self.tempView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                    
                } else {
                    
                    self.tempView.frame = CGRectMake(-self.view.width, 0, self.view.width, self.view.height);
                }
                
                [self animateSuccess:isSuccess];
            }
            
        } else { // 右边
            
            if (animated) {
                
                __weak WXYZ_ScorllPageViewController *weakSelf = self;
                
                [UIView animateWithDuration:AnimateDuration animations:^{
                    
                    if (isSuccess) {
                        
                        weakSelf.currentView.frame = CGRectMake(-self.view.width, 0, self.view.width, self.view.height);
                        weakSelf.tempView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                        
                    } else {
                        
                        weakSelf.currentView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                        weakSelf.tempView.frame = CGRectMake(self.view.width, 0, self.view.width, self.view.height);
                    }
                    
                } completion:^(BOOL finished) {
                    
                    [weakSelf animateSuccess:isSuccess];
                }];
                
            } else {
                
                if (isSuccess) {
                    
                    self.currentView.frame = CGRectMake(-self.view.width, 0, self.view.width, self.view.height);
                    
                } else {
                    
                    self.currentView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                }
                
                [self animateSuccess:isSuccess];
            }
        }
    }
    
    self.haveNextPager = [[WXYZ_ReaderBookManager sharedManager] haveNextPager];
}

/**
 *  动画结束
 */
- (void)animateSuccess:(BOOL)isSuccess {
    if (isSuccess) {
        
        [self.currentView removeFromSuperview];
        
        _currentView = self.tempView;
        
        self.tempView = nil;
        
        self.isAnimating = NO;
        if (self.isLeft) {
            self.currentIndex --;
        } else {
            self.currentIndex ++;
        }
    } else {
        
        [self.tempView removeFromSuperview];
        
        self.tempView = nil;
        
        self.isAnimating = NO;
        
        if (self.isLeft) {
            [self.dataSource dp_pageController:self viewForIndex:self.lastIndex direction:DPPageRollingDirectionRight];
        } else {
            [self.dataSource dp_pageController:self viewForIndex:self.nextIndex direction:DPPageRollingDirectionLeft];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(dp_pageController:currentView:currentIndex:)]) {
        [self.delegate dp_pageController:self currentView:self.currentView currentIndex:self.currentIndex];
    }
}

#pragma mark - 设置显示View

/**
 *  添加View
 *
 *  @param view 显示View
 */
- (void)addView:(UIView * _Nullable)view {
    if (view) {
        
        if (self.isLeft) { // 左边
            
            [self.view addSubview:view];
            
//            view.frame = CGRectMake(-self.view.width, 0, self.view.width, self.view.height);
            
        } else { // 右边
            
            if (self.currentView) { // 有值
                
                [self.view insertSubview:view belowSubview:self.currentView];
                
            } else { // 没值
                
                [self.view addSubview:view];
            }
            
//            view.frame = CGRectMake(0, 0, self.view.width, self.view.height);
        }
    }
}

#pragma mark - Method
- (void)reloadData {
    
    if ([self.dataSource respondsToSelector:@selector(dp_numberOfPagesInPageController:)]) {
        _numberOfPages = [self.dataSource dp_numberOfPagesInPageController:self];
        
        if (_numberOfPages <= 0) return;
        
        if (self.currentIndex && self.currentIndex < self.numberOfPages) {
            self.currentIndex = self.currentIndex;
            //            return;
        }
        self.currentIndex = 0;
        if ([self.dataSource respondsToSelector:@selector(dp_pageController:viewForIndex:direction:)]) {
            self.tempView = [self.dataSource dp_pageController:self viewForIndex:self.currentIndex direction:DPPageRollingDirectionNone];
            [self initView];
        }
    }
}

- (void)reloadDataToFirst {
    
    if ([self.dataSource respondsToSelector:@selector(dp_numberOfPagesInPageController:)]) {
        _numberOfPages = [self.dataSource dp_numberOfPagesInPageController:self];
        
        if (_numberOfPages <= 0) return;
        
        self.currentIndex = 0;

        if ([self.dataSource respondsToSelector:@selector(dp_pageController:viewForIndex:direction:)]) {
            self.tempView = [self.dataSource dp_pageController:self viewForIndex:self.currentIndex direction:DPPageRollingDirectionNone];
            [self initView];
        }
    }
}

- (void)initView {
    // 添加
    [self addView:self.tempView];
    
    if (self.isAnimating) {
        __weak WXYZ_ScorllPageViewController *weakSelf = self;
        
        if (self.isLeft) {
            [self.view bringSubviewToFront:self.currentView];
            self.tempView.frame = CGRectMake(- self.view.width, 0, self.view.width, self.view.height);
            [UIView animateWithDuration:AnimateDuration animations:^{
                weakSelf.tempView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                weakSelf.currentView.frame = CGRectMake(self.view.width, 0, self.view.width, self.view.height);
                
            } completion:^(BOOL finished) {
                [weakSelf initViewComplented];
            }];
        } else {
            self.tempView.frame = CGRectMake(self.view.width, 0, self.view.width, self.view.height);
            [UIView animateWithDuration:AnimateDuration animations:^{
                weakSelf.currentView.frame = CGRectMake(-self.view.width, 0, self.view.width, self.view.height);
                weakSelf.tempView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
            } completion:^(BOOL finished) {
                [weakSelf initViewComplented];
            }];
        }
        return;
    }
    
    // 修改frame
    self.tempView.frame = self.view.bounds;
    [self initViewComplented];
    
}

- (void)initViewComplented {
    self.isAnimating = NO;
    // 当前View有值 进行删除
    if (_currentView) {
        
        [_currentView removeFromSuperview];
        
        _currentView = nil;
    }
    
    // 赋值记录
    _currentView = self.tempView;
    self.tempView = nil;
    if ([self.delegate respondsToSelector:@selector(dp_pageController:currentView:currentIndex:)]) {
        [self.delegate dp_pageController:self currentView:self.currentView currentIndex:self.currentIndex];
    }
}

- (BOOL)canSwitchToIndex:(NSInteger)index {
    if (index < 0) {
        return NO;
    }
    if (index > self.numberOfPages - 1) {
        return NO;
    }
    return YES;
}

- (void)switchToIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.currentIndex == index) {
        return;
    }
    self.isAnimating = animated;
    self.isLeft = NO;
    self.currentIndex = index;
    
    if ([self.dataSource respondsToSelector:@selector(dp_pageController:viewForIndex:direction:)]) {
        self.tempView = [self.dataSource dp_pageController:self viewForIndex:self.currentIndex direction:DPPageRollingDirectionRight];
        [self initView];
    }
}

#pragma mark - getter/setter

- (void)setCurrentIndex:(NSInteger)currentIndex {
    
    if (self.circleSwitchEnabled) {
        if (currentIndex == -1) {
            currentIndex = self.numberOfPages - 1;
        } else if (currentIndex == self.numberOfPages) {
            currentIndex = 0;
        }
    } else {
        self.scrollToNextEnabled = self.scrollToLastEnabled = YES;
        if (currentIndex == 0) {
            self.scrollToLastEnabled = NO;
        }
        if (currentIndex == self.numberOfPages - 1) {
            self.scrollToNextEnabled = NO;
        }
    }
    _currentIndex = currentIndex;
    
    if (currentIndex == 0) {
        if ([self.delegate respondsToSelector:@selector(dp_pageControllerDidSwitchToFirst:)]) {
            [self.delegate dp_pageControllerDidSwitchToFirst:self];
        }
    }
    
    if (currentIndex == self.numberOfPages - 1) {
        if ([self.delegate respondsToSelector:@selector(dp_pageControllerDidSwitchToLast:)]) {
            [self.delegate dp_pageControllerDidSwitchToLast:self];
        }
    }
}


- (NSInteger)lastIndex {
    NSInteger lastIndex = self.currentIndex - 1;
    
    if (!self.circleSwitchEnabled) return lastIndex;
    
    if (lastIndex < 0) {
        lastIndex = self.numberOfPages - 1;
    }
    
    return lastIndex;
}

- (NSInteger)nextIndex {
    NSInteger nextIndex = self.currentIndex + 1;
    
    if (!self.circleSwitchEnabled) return nextIndex;
    
    if (nextIndex >= self.numberOfPages) {
        nextIndex = 0;
    }
    
    return nextIndex;
}

- (void)setSwitchTapEnabled:(BOOL)switchTapEnabled {
    _switchTapEnabled = switchTapEnabled;
    self.tap.enabled = switchTapEnabled;
}

- (void)setSwitchSlideEnabled:(BOOL)switchSlideEnabled {
    _switchSlideEnabled = switchSlideEnabled;
    self.pan.enabled = switchSlideEnabled;
}

@end
