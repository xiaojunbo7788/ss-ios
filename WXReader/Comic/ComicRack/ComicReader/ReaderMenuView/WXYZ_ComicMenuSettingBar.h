//
//  WXYZ_ComicMenuSettingBar.h
//  WXReader
//
//  Created by Andrew on 2019/6/5.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_ComicMenuSettingBarDelegate <NSObject>

- (void)changeMode:(int)mode;

@end

@interface WXYZ_ComicMenuSettingBar : UIView

@property (nonatomic, weak) id<WXYZ_ComicMenuSettingBarDelegate>delegate;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

- (void)changeMode:(int)mode;

- (void)showSettingBar;

- (id)initWithMode:(int)mode;

@end

NS_ASSUME_NONNULL_END
