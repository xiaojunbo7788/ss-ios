//
//  WXYZ_TagHeadView.h
//  WXReader
//
//  Created by geng on 2020/9/15.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_TagHeadViewDelegate <NSObject>

- (void)selectSort:(NSString *)sort;

@end

@interface WXYZ_TagHeadView : UIView

@property (nonatomic, weak) id<WXYZ_TagHeadViewDelegate>delegate;

@property (nonatomic, strong) UILabel *titleView;

@end

NS_ASSUME_NONNULL_END
