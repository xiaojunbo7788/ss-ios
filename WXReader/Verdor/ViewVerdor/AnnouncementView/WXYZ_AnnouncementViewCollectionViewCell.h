//
//  WXYZ_AnnouncementViewCollectionViewCell.h
//  GKADRollingView
//
//  Created by Gao on 2017/2/16.
//  Copyright © 2017年 gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_RackCenterModel.h"

@interface WXYZ_AnnouncementViewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_AnnouncementModel *announcementModel;

@property (nonatomic, strong) UIColor *titleColor;      // default is orange

@property (nonatomic, strong) UIFont *textFont;         // default is 12

@property (nonatomic, strong) UIColor *textColor;       // default is black

/// 文字是否居中
@property (nonatomic, assign) BOOL isCenter;

@end
