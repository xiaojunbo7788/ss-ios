//
//  WXYZ_ComicMenuTopBar.h
//  WXReader
//
//  Created by Andrew on 2019/6/4.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicMenuTopBar : UIView

- (void)showMenuTopBar;

- (void)hiddenMenuTopBar;

- (void)setNavTitle:(NSString *)titleString;

@end

NS_ASSUME_NONNULL_END
