//
//  WXYZ_ComicMenuBottomBar.h
//  WXReader
//
//  Created by Andrew on 2019/6/4.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ComicMenuSettingBar.h"
#define Comic_Menu_Bottom_Bar_Top_Height 40

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicMenuBottomBar : UIView <YYTextViewDelegate>

@property (nonatomic, weak) id<WXYZ_ComicMenuSettingBarDelegate>delegate;
@property (nonatomic, strong) WXYZ_ProductionChapterModel *comicChapterModel;

@property (nonatomic, strong) WXYZ_ProductionModel *productionModel;

- (instancetype)initWithMode:(int)mode;

- (void)changeMode:(int)mode;

- (void)showMenuBottomBar;

- (void)hiddenMenuBottomBar;

- (void)startLoadingData;

- (void)stopLoadingData;

- (void)reloadCollectionState;

@end

NS_ASSUME_NONNULL_END
