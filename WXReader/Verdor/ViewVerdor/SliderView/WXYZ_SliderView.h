//
//  DPSliderView.h
//  WXReader
//
//  Created by Andrew on 2018/6/5.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXYZ_SliderView;

@protocol DPSliderViewDelegate <NSObject>

- (void)sliderValueEndChanged:(CGFloat)endValue slider:(WXYZ_SliderView *)sender;

@end

@interface WXYZ_SliderView : UIView

@property(nonatomic, weak) id<DPSliderViewDelegate> delegate;

// 分段式滑块 Default is NO
@property (nonatomic, assign) BOOL stepSlider;

// 倒置返回值
@property (nonatomic, assign) BOOL invertedValue;

// 最小值
@property (nonatomic, assign) CGFloat minimumValue;

// 最大值
@property (nonatomic, assign) CGFloat maximumValue;

// 滑块值
@property (nonatomic, assign) CGFloat sliderValue;

// 左侧滑条颜色
@property (nonatomic, strong) UIColor *minimumTintColor;

// 右侧滑条颜色
@property (nonatomic, strong) UIColor *maximumTintColor;

// 左侧图片名称
@property (nonatomic, copy) NSString *leftImageName;

// 右侧图片名称
@property (nonatomic, copy) NSString *rightImageName;

// 左侧图片
@property (nonatomic, strong) UIImage *leftImage;

// 右侧图片
@property (nonatomic, strong) UIImage *rightImage;

- (instancetype)initWithFrame:(CGRect)frame sliderCutPointCount:(NSUInteger)cutPointCount;

@end
