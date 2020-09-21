//
//  WXReaderContentManager.h
//  WXReader
//
//  Created by Andrew on 2018/5/30.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WXReaderTransitionStyle) {
    WXReaderTransitionStylePageCurl = 0,
    WXReaderTransitionStyleScroll   = 1,
    WXReaderTransitionStyleCover    = 2,
    WXReaderTransitionStyleNone     = 3
};

typedef NS_ENUM(NSUInteger, WXReaderAutoReadState) {
    WXReaderAutoReadStateStop   = 0, // 停止
    WXReaderAutoReadStateStart  = 1, // 开启
    WXReaderAutoReadStatePause  = 2, // 暂停
    WXReaderAutoReadStateResume = 3, // 恢复
};

typedef NS_ENUM(NSUInteger, WXReaderLineSpacingState) {
    WXReaderLineSpacingStateBig      = 0,
    WXReaderLineSpacingStateMedium   = 1,
    WXReaderLineSpacingStateSmall    = 2
};

typedef NS_ENUM(NSUInteger, WXReaderPatternMode) {
    WXReaderPatternModeDaytime    = 0,
    WXReaderPatternModeNight      = 1
};

typedef NS_ENUM(NSUInteger, WXReaderBackColorMode) {
    WXReaderBackColorYellow,
    WXReaderBackColorGreen,
    WXReaderBackColorBlue,
    WXReaderBackColorPink,
    WXReaderBackColorWhite,
    WXReaderBackColorGray,
    WXReaderBackColorBlack
};

static CGFloat line_spacing_small   = 5.0f;
static CGFloat line_spacing_medium  = 10.0f;
static CGFloat line_spacing_big     = 20.0f;

typedef void(^ReaderFontChanged)(void);
typedef void(^ReaderBackgroundViewChanged)(void);
typedef void(^ReaderBrightnessChanged)(void);
typedef void(^ReaderLinesSpacingChanged)(void);
typedef void(^ReaderTransitionStyleChanged)(WXReaderTransitionStyle transitionStyle);
typedef void(^ReaderAutoReaderStateChanged)(WXReaderAutoReadState state);
typedef void(^ReaderAutoReadSpeedChanged)(NSInteger readSpeed);


@interface WXYZ_ReaderSettingHelper : NSObject

// 字体改变
@property (nonatomic, copy) ReaderFontChanged readerFontChanged;

// 背景改变
@property (nonatomic, copy) ReaderBackgroundViewChanged readerBackgroundViewChanged;

// 亮度改变
@property (nonatomic, copy) ReaderBrightnessChanged readerBrightnessChanged;

// 间距改变
@property (nonatomic, copy) ReaderLinesSpacingChanged readerLinesSpacingChanged;

// 翻页样式改变
@property (nonatomic, copy) ReaderTransitionStyleChanged readerTransitionStyleChanged;

// 自动阅读启动或者停止
@property (nonatomic, copy) ReaderAutoReaderStateChanged readerAutoReaderStateChanged;

// 改变自动阅读时间
@property (nonatomic, copy) ReaderAutoReadSpeedChanged readerAutoReadSpeedChanged;

/**
 单例方法
 
 @return self
 */
interface_singleton

@property (nonatomic, assign) WXReaderAutoReadState state;

// 开启屏幕常亮
- (void)openScreenKeep;

// 关闭屏幕常亮
- (void)closeScreenKeep;

// 隐藏状态栏
- (void)hiddenStatusBar;

// 显示状态栏
- (void)showStatusBar;

/*
 Font
 */

// 设置字号
- (void)setReaderFontSize:(CGFloat)fontSize;

// 获取字号
- (CGFloat)getReaderFontSize;

- (CGFloat)getReaderMinFontSize;

- (CGFloat)getReaderMaxFontSize;

// 设置行间距
- (void)setReaderLinesSpacing:(CGFloat)linesSpacing;

// 获取行间距
- (CGFloat)getReaderLinesSpacing;

// 获取行间距类型
- (WXReaderLineSpacingState)getReaderLineSpacingState;

/*
 Frame
 */

// 获取页面size
- (CGSize)getReaderViewSize;

// 获取页面frame
- (CGRect)getReaderViewFrame;

// 获取页面bottom
- (CGFloat)getReaderViewBottom;

/*
 Color
 */

// 设置背景色
- (void)setReaderBackgroundColor:(WXReaderBackColorMode)colorMode;

// 获取背景色枚举值
- (WXReaderBackColorMode)getReaderBackgroundColorMode;

// 获取背景色
- (UIColor *)getReaderBackgroundColor;

// 背景颜色合集
- (NSArray *)getReaderBackgroundColorModeArray;

// 获取字体颜色
- (UIColor *)getReaderTextColor;

// 获取标题字体颜色
- (UIColor *)getReaderTitleTextColor;

// 获取夜间模式状态
- (WXReaderPatternMode)getNightModeState;

// 设置夜间模式状态
- (void)setNightModeState:(WXReaderPatternMode)state;


/*
 Brightness
 */

// 获取屏幕亮度
- (CGFloat)getBrightness;

// 设定屏幕亮度
- (void)setBrightness:(CGFloat)brightness;

/*
 TransitionStyle
 */
// 设置翻页类型
- (void)setTransitionStyle:(WXReaderTransitionStyle)transitionStyle;

// 获取翻页类型
- (WXReaderTransitionStyle)getTransitionStyle;

/*
 RecordLocation
 */
// 获取记录章节
- (NSInteger)getMemoryChapterIndexWithBook_id:(NSUInteger)book_id;

// 获取记录页数
- (NSInteger)getMemoryPagerIndexWithBook_id:(NSUInteger)book_id;

// 记录章节 页数
- (void)setLocationMemoryOfChapterIndex:(NSInteger)chapterIndex pagerIndex:(NSInteger)pagerIndex book_id:(NSUInteger)book_id;

/*
 设置阅读速度
 */
// 设置阅读速度
- (void)setReadSpeed:(NSUInteger)animationDuration;

// 获取阅读速度
- (NSUInteger)getReadSpeed;

// 开启或关闭自动阅读
- (void)setAutoReaderState:(WXReaderAutoReadState)state;

@end
