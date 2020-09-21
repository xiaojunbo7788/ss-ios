//
//  WXReaderContentManager.m
//  WXReader
//
//  Created by Andrew on 2018/5/30.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_ReaderSettingHelper.h"
#import "AppDelegate.h"

#define PUB_DEFAULT_READ_SPEED 10

#define PUB_MIN_READ_SPEED 5

#define PUB_MAX_READ_SPEED 60

@implementation WXYZ_ReaderSettingHelper

implementation_singleton(WXYZ_ReaderSettingHelper)

#pragma mark - Screen
// 开启屏幕常亮
- (void)openScreenKeep
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

// 关闭屏幕常亮
- (void)closeScreenKeep
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - Status
- (void)hiddenStatusBar
{
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)showStatusBar
{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - Font

- (void)setReaderFontSize:(CGFloat)fontSize
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:fontSize] forKey:WX_READER_FONT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.readerFontChanged) {
        self.readerFontChanged();
    }
}

- (CGFloat)getReaderFontSize
{
    CGFloat textFontSize = [[[NSUserDefaults standardUserDefaults] objectForKey:WX_READER_FONT] floatValue];
    
    if (!textFontSize || textFontSize <= [self getReaderMinFontSize]) {
        return [self getReaderMinFontSize];
    }
    
    if (textFontSize >= [self getReaderMaxFontSize]) {
        return [self getReaderMaxFontSize];
    }
    
    return textFontSize;
}

- (CGFloat)getReaderMinFontSize
{
    return kFontSize15;
}

- (CGFloat)getReaderMaxFontSize
{
    return kFontSize30;
}

// 设置行间距
- (void)setReaderLinesSpacing:(CGFloat)linesSpacing
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:linesSpacing] forKey:WX_READER_LINESPACING];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.readerLinesSpacingChanged) {
        self.readerLinesSpacingChanged();
    }
}

// 获取行间距
- (CGFloat)getReaderLinesSpacing
{
    CGFloat t_linesSpacing = [[[NSUserDefaults standardUserDefaults] objectForKey:WX_READER_LINESPACING] floatValue];
    if (t_linesSpacing == 0) {
        [self setReaderLinesSpacing:line_spacing_medium];
        return line_spacing_medium;
    }
    return t_linesSpacing;
}

- (WXReaderLineSpacingState)getReaderLineSpacingState
{
    CGFloat t_lineSpacing = [self getReaderLinesSpacing];
    if (t_lineSpacing == line_spacing_small) {
        return WXReaderLineSpacingStateSmall;
    } else if (t_lineSpacing == line_spacing_medium) {
        return WXReaderLineSpacingStateMedium;
    } else {
        return WXReaderLineSpacingStateBig;
    }
}

#pragma mark -  Frame

- (CGSize)getReaderViewSize
{
    return [self getReaderViewFrame].size;
}

- (CGRect)getReaderViewFrame
{
    
    AppDelegate *appDelegate = (AppDelegate *)kRCodeSync([[UIApplication sharedApplication] delegate]);
    if (!appDelegate.checkSettingModel.ad_status_setting.chapter_read_bottom) {
        return CGRectMake(kMargin,
                          2 * kMargin + PUB_NAVBAR_OFFSET + 10,
                          SCREEN_WIDTH - 2 * kMargin,
                          SCREEN_HEIGHT - 2 * kMargin - PUB_NAVBAR_OFFSET - PUB_TABBAR_OFFSET - 2 * kHalfMargin - kMargin);
    }
    return CGRectMake(kMargin,
                      2 * kMargin + PUB_NAVBAR_OFFSET + 10,
                      SCREEN_WIDTH - 2 * kMargin,
                      SCREEN_HEIGHT - 2 * kMargin - PUB_NAVBAR_OFFSET - 2 * kHalfMargin - kMargin - PUB_TABBAR_HEIGHT - (is_iPhoneX?-kMargin:0));
}

- (CGFloat)getReaderViewBottom
{
    return [self getReaderViewFrame].origin.y + [self getReaderViewFrame].size.height;
}

#pragma mark -  Color

// 设置背景色
- (void)setReaderBackgroundColor:(WXReaderBackColorMode)colorMode
{
    if ([self getNightModeState] == WXReaderPatternModeNight) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:colorMode] forKey:@"wx_back_color"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([self getNightModeState] == WXReaderPatternModeDaytime) {
        if (self.readerBackgroundViewChanged) {
            self.readerBackgroundViewChanged();
        }
    }
}

// 获取背景色枚举值
- (WXReaderBackColorMode)getReaderBackgroundColorMode
{
    if ([self getNightModeState] == WXReaderPatternModeNight) {
        return WXReaderBackColorBlack;
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"wx_back_color"] integerValue];
}

// 获取背景色
- (UIColor *)getReaderBackgroundColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:[[self getReaderBackgroundColorModeArray] objectAtIndex:[self getReaderBackgroundColorMode]]]];
}


- (NSArray *)getReaderBackgroundColorModeArray
{
    return @[@"read_page_bg_yellow.png", @"read_page_bg_green.png", @"read_page_bg_blue.png", @"read_page_bg_pink.png", @"read_page_bg_white.png", @"read_page_bg_gray.png", @"read_page_bg_black.png"];
}

// 获取字体颜色
- (UIColor *)getReaderTextColor
{
    switch ([self getReaderBackgroundColorMode]) {
        case WXReaderBackColorYellow:
            return kColorRGBA(92, 66, 45, 1);
        case WXReaderBackColorGreen:
            return kColorRGBA(69, 81, 72, 1);
            break;
        case WXReaderBackColorBlue:
            return kColorRGBA(50, 63, 74, 1);
            break;
        case WXReaderBackColorPink:
            return kColorRGBA(144, 38, 61, 1);
            break;
        case WXReaderBackColorWhite:
            return kBlackColor;
            break;
        case WXReaderBackColorGray:
            return kColorRGBA(159, 161, 163, 1);
            break;
        case WXReaderBackColorBlack:
            return kColorRGBA(127, 127, 127, 1);
            break;
            
        default:
            break;
    }
}

// 获取标题字体颜色
- (UIColor *)getReaderTitleTextColor
{
    CGFloat alpha = 0.5;
    switch ([self getReaderBackgroundColorMode]) {
        case WXReaderBackColorYellow:
            return kColorRGBA(92, 66, 45, alpha);
        case WXReaderBackColorGreen:
            return kColorRGBA(69, 81, 72, alpha);
            break;
        case WXReaderBackColorBlue:
            return kColorRGBA(50, 63, 74, alpha);
            break;
        case WXReaderBackColorPink:
            return kColorRGBA(144, 38, 61, alpha);
            break;
        case WXReaderBackColorWhite:
            return kColorRGBA(33, 34, 35, alpha);
            break;
        case WXReaderBackColorGray:
            return kColorRGBA(159, 161, 163, alpha);
            break;
        case WXReaderBackColorBlack:
            return kColorRGBA(127, 127, 127, alpha);
            break;
            
        default:
            break;
    }
}

// 获取夜间模式状态
- (WXReaderPatternMode)getNightModeState
{
    NSInteger nightModeState = [[[NSUserDefaults standardUserDefaults] objectForKey:WX_READER_NIGHT_MODE] integerValue];
    if (nightModeState == 0) {
        return WXReaderPatternModeDaytime;
    }
    
    return WXReaderPatternModeNight;
}

// 设置夜间模式状态
- (void)setNightModeState:(WXReaderPatternMode)state
{
    if (state == WXReaderPatternModeDaytime) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:0] forKey:WX_READER_NIGHT_MODE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:1] forKey:WX_READER_NIGHT_MODE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (self.readerBackgroundViewChanged) {
        self.readerBackgroundViewChanged();
    }
}

#pragma mark -  Brightness
// 获取屏幕亮度
- (CGFloat)getBrightness
{
    CGFloat brightness =  [UIScreen mainScreen].brightness;
    return brightness;
}

// 设定屏幕亮度
- (void)setBrightness:(CGFloat)brightness
{
    [[UIScreen mainScreen] setBrightness:brightness];
    if (self.readerBrightnessChanged) {
        self.readerBrightnessChanged();
    }
}

#pragma mark -  TransitionStyle
// 设置翻页类型
- (void)setTransitionStyle:(WXReaderTransitionStyle)transitionStyle
{
    NSUInteger t_tStyle = 0;
    switch (transitionStyle) {
        case WXReaderTransitionStylePageCurl:
            t_tStyle = 0;
            break;
        case WXReaderTransitionStyleScroll:
            t_tStyle = 1;
            break;
        case WXReaderTransitionStyleCover:
            t_tStyle = 2;
            break;
        case WXReaderTransitionStyleNone:
            t_tStyle = 3;
            break;
            
        default:
            break;
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:t_tStyle] forKey:WX_READER_TRANSITION_STYLE];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (self.readerTransitionStyleChanged) {
        self.readerTransitionStyleChanged(transitionStyle);
    }
}

// 获取翻页类型
- (WXReaderTransitionStyle)getTransitionStyle
{
    NSUInteger t_transitionStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:WX_READER_TRANSITION_STYLE] unsignedIntegerValue];
    
    switch (t_transitionStyle) {
        case 0:
            return WXReaderTransitionStylePageCurl;
            break;
        case 1:
            return WXReaderTransitionStyleScroll;
            break;
        case 2:
            return WXReaderTransitionStyleCover;
            break;
        case 3:
            return WXReaderTransitionStyleNone;
            break;
            
        default:
            break;
    }
    
    return t_transitionStyle;
}

#pragma mark -  RecordLocation
// 获取记录章节
- (NSInteger)getMemoryChapterIndexWithBook_id:(NSUInteger)book_id
{
    NSUInteger t_chapterIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",WX_READER_CHAPTER_INDEX, [WXYZ_UtilsHelper formatStringWithInteger:book_id]]] integerValue];
    return t_chapterIndex;
}

// 获取记录页数
- (NSInteger)getMemoryPagerIndexWithBook_id:(NSUInteger)book_id
{
    NSUInteger t_pagerIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",WX_READER_PAGER_INDEX, [WXYZ_UtilsHelper formatStringWithInteger:book_id]]] unsignedIntegerValue];
    return t_pagerIndex;
}

// 记录章节 页数
- (void)setLocationMemoryOfChapterIndex:(NSInteger)chapterIndex pagerIndex:(NSInteger)pagerIndex book_id:(NSUInteger)book_id
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:chapterIndex] forKey:[NSString stringWithFormat:@"%@_%@",WX_READER_CHAPTER_INDEX, [WXYZ_UtilsHelper formatStringWithInteger:book_id]]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:pagerIndex] forKey:[NSString stringWithFormat:@"%@_%@",WX_READER_PAGER_INDEX, [WXYZ_UtilsHelper formatStringWithInteger:book_id]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 设置阅读速度
 */
// 设置阅读速度
- (void)setReadSpeed:(NSUInteger)animationDuration
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:animationDuration] forKey:WX_READER_READ_SPEED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.readerAutoReadSpeedChanged) {
        self.readerAutoReadSpeedChanged(animationDuration);
    }
}

// 获取阅读速度
- (NSUInteger)getReadSpeed
{
    NSInteger t_readSpeed = [[[NSUserDefaults standardUserDefaults] objectForKey:WX_READER_READ_SPEED] unsignedIntegerValue];
    
    if (t_readSpeed == 0) {
        return PUB_DEFAULT_READ_SPEED;
    }
    
    if (t_readSpeed < PUB_MIN_READ_SPEED) {
        return PUB_MIN_READ_SPEED;
    }
    
    if (t_readSpeed > kFontSize30) {
        return PUB_MAX_READ_SPEED;
    }
    
    return t_readSpeed;
}

- (void)setAutoReaderState:(WXReaderAutoReadState)state
{
    self.state = state;
    if (self.readerAutoReaderStateChanged) {
        self.readerAutoReaderStateChanged(state);
    }
}

@end
