//
//  WXYZ_AudioMallCenterViewController.h
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioMallCenterViewController : WXYZ_BasicViewController

@property (nonatomic, assign) CGFloat channel;

@property (nonatomic, assign) CGFloat scrollViewContentOffsetY;

@property (nonatomic, strong) NSArray *hotwordArray;

@end

NS_ASSUME_NONNULL_END
