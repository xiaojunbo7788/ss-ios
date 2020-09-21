//
//  WXYZ_AnnouncementView.h
//  GKADRollingView
//
//  Created by Gao on 2017/2/16.
//  Copyright © 2017年 gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_AnnouncementViewCollectionViewCell.h"

@interface WXYZ_AnnouncementView : UIView

typedef void(^WXYZ_AnnouncementViewTapBlock) (NSString *path, NSUInteger index);

@property (nonatomic, copy) WXYZ_AnnouncementViewTapBlock clickAdBlock;

@property (nonatomic, strong) NSArray<WXYZ_AnnouncementModel *> *modelArr;

@property (nonatomic, strong) UIColor *titleColor;      // default is orange

@property (nonatomic, strong) UIFont *textFont;         // default is 12

@property (nonatomic, strong) UIColor *textColor;       // default is black

@property (nonatomic, assign) NSTimeInterval duration;  // default is 3s

/// 是否居中，默认靠左
@property (nonatomic, assign) BOOL isCenter;

@end
