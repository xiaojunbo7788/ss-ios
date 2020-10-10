//
//  WXZY_NoticeAlertView.h
//  WXReader
//
//  Created by geng on 2020/10/10.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXZY_NoticeAlertView : UIView

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, copy) NSString *msg;
- (void)showInView:(UIView *)view;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
