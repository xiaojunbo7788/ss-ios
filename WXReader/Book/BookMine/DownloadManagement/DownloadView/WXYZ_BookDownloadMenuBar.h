//
//  WXYZ_BookDownloadMenuBar.h
//  WXReader
//
//  Created by Andrew on 2019/4/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_ProductionModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookDownloadMenuBar : UIView

@property (nonatomic, copy) NSString *book_id;

@property (nonatomic, copy) NSString *chapter_id;

@property (nonatomic, copy) void (^menuBarDidHiddenBlock)(void);

- (void)showDownloadPayView;

- (void)hiddenDownloadPayView;

@end

NS_ASSUME_NONNULL_END
