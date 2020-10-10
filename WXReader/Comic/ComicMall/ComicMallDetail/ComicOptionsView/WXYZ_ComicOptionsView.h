//
//  WXYZ_ComicOptionsView.h
//  WXReader
//
//  Created by geng on 2020/10/10.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_ComicOptionsViewDelegate <NSObject>

- (void)changeLineData;
- (void)changeClearData;

@end

@interface WXYZ_ComicOptionsView : UIView

@property (nonatomic, weak) id<WXYZ_ComicOptionsViewDelegate>delegate;
- (void)refreshStateView;

@end

NS_ASSUME_NONNULL_END
