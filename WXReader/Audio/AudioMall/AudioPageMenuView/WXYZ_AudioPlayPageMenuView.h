//
//  WXYZ_AudioPlayPageMenuView.h
//  WXReader
//
//  Created by Andrew on 2020/3/18.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_MenuType) {
    WXYZ_MenuTypeAudioSpeed,     // 有声语速
    WXYZ_MenuTypeAudioDirectory, // 有声目录
    WXYZ_MenuTypeAudioSelection, // 有声选章
    
    WXYZ_MenuTypeAiSpeed,     // ai语速
    WXYZ_MenuTypeAiVoice,     // ai声音
    WXYZ_MenuTypeAiDirectory, // ai目录
    
    WXYZ_MenuTypeTiming  // 定时
};

@interface WXYZ_AudioPlayPageMenuView : UIView <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *menuListArray;

/// 总章节数量
@property (nonatomic, assign) NSInteger totalChapter;

@property (nonatomic, copy) void (^chooseMenuBlock)(WXYZ_MenuType menuType, NSInteger chooseIndex);

@property (nonatomic, copy) void (^chooseDirectoryMenuBlock)(NSInteger chapter_id, NSInteger chooseIndex);

@property (nonatomic, copy) void (^timingCompleteBlock)(BOOL finish);

- (void)showWithMenuType:(WXYZ_MenuType)menuType;

- (void)close;

@end

NS_ASSUME_NONNULL_END
