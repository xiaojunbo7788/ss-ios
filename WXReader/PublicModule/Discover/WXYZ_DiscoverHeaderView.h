//
//  WXYZ_DiscoverHeaderView.h
//  WXReader
//
//  Created by Andrew on 2018/11/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BannerrImageClickBlock)(WXYZ_BannerModel *bannerModel);

@interface WXYZ_DiscoverHeaderView : UIView

@property (nonatomic, copy) BannerrImageClickBlock bannerrImageClickBlock;        //banner点击

@property (nonatomic, strong) NSArray <WXYZ_BannerModel *>*banner;

@end

NS_ASSUME_NONNULL_END
