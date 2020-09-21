//
//  WXBookReaderToolBar.m
//  WXReader
//
//  Created by Andrew on 2018/5/30.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BookReaderMenuBar.h"
#import "WXYZ_ReaderSettingHelper.h"

#import "WXYZ_BookReaderTopBar.h"
#import "WXYZ_BookReaderBottomBar.h"

#if WX_Enable_Ai
    #import "WXYZ_TouchAssistantView.h"
#endif

#define ToolBar_Normal_Height (60 + PUB_TABBAR_OFFSET)

@interface WXYZ_BookReaderMenuBar ()
{
    // 导航条
    WXYZ_BookReaderTopBar *navBar;
    // 工具条
    WXYZ_BookReaderBottomBar *toolBar;
    
    WXYZ_ReaderSettingHelper *functionalManager;
}

@end

@implementation WXYZ_BookReaderMenuBar

implementation_singleton(WXYZ_BookReaderMenuBar)

- (instancetype)init
{
    if (self = [super init]) {
        
        [self initialize];
        
        [self createSubViews];
    }
    return self;
}

- (void)initialize
{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    [kMainWindow addSubview:self];
    
    self.hidden = YES;
    
    functionalManager = [WXYZ_ReaderSettingHelper sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddend) name:NSNotification_Hidden_Bottom_ToolNav object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint toolBarPoint = [toolBar.layer convertPoint:[touch locationInView:self] fromLayer:self.layer];
    CGPoint navBarPoint = [navBar.layer convertPoint:[touch locationInView:self] fromLayer:self.layer];
    if (![toolBar.layer containsPoint:toolBarPoint] && ![navBar.layer containsPoint:navBarPoint]) {
        [self hiddend];
    }
}

- (void)hiddend
{
    if (functionalManager.state == WXReaderAutoReadStateStart && self.hidden) {
        [self show];
        return;
    }
    [navBar hiddenNavBarCompletion:^{
        self.hidden = YES;
    }];
    [toolBar hiddenToolBar];
    
#if WX_Enable_Ai
    [[WXYZ_TouchAssistantView sharedManager] hiddenAssistiveTouchView];
#endif
    
}

- (void)show
{
    [kMainWindow bringSubviewToFront:self];
    self.hidden = NO;
    if (!toolBar.autoReading) {
        [navBar showNavBarCompletion:^{
            
        }];
        if (!isMagicState) {
            [toolBar showToolBar];
        }
    } else {
        [functionalManager setAutoReaderState:WXReaderAutoReadStatePause];
        [navBar hiddenNavBarCompletion:^{
            
        }];
        [toolBar showAutoReadToolBar];
    }
    
#if WX_Enable_Ai
    [[WXYZ_TouchAssistantView sharedManager] showAssistiveTouchView];
#endif
}

- (void)createSubViews
{
    navBar = [[WXYZ_BookReaderTopBar alloc] initWithFrame:CGRectMake(0, - PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, PUB_NAVBAR_HEIGHT)];
    [self addSubview:navBar];
    
    toolBar = [[WXYZ_BookReaderBottomBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, ToolBar_Normal_Height)];
    [self addSubview:toolBar];
    
}

- (void)stopAutoRead
{
    [toolBar stopAutoRead];
}

- (void)popViewContriller
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification_Reader_Back object:nil];
    [self stopAutoRead];
}

@end
