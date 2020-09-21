//
//  DPMoreView.h
//  WXReader
//
//  Created by Andrew on 2018/5/26.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WXYZ_TagAlignment) {
    WXYZ_TagAlignmentLeft,
    WXYZ_TagAlignmentRight,
    WXYZ_TagAlignmentCenter
};

typedef NS_ENUM(NSUInteger, WXYZ_TagBorderStyle) {
    WXYZ_TagBorderStyleBorder,
    WXYZ_TagBorderStyleFill,
    WXYZ_TagBorderStyleNone,
};

@interface WXYZ_TagView : UIView

@property (nonatomic, strong) NSArray *tagArray;

@property (nonatomic, strong) UIFont *tagViewFont;

@property (nonatomic, assign) CGFloat tagViewCornerRadius;

@property (nonatomic, assign) CGFloat tagSpacing;

@property (nonatomic, assign) CGFloat tagMergeAllowance;

@property (nonatomic, assign) WXYZ_TagBorderStyle tagBorderStyle;

@property (nonatomic, assign) WXYZ_TagAlignment tagAlignment;

@property (nonatomic, copy) void (^tagViewWidthUpdate)(CGFloat width);

@end
