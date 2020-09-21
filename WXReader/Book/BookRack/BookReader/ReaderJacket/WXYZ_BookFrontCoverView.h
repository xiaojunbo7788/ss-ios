//
//  WXYZ_BookFrontCoverView.h
//  WXReader
//
//  Created by LL on 2020/5/23.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_ReaderSettingHelper;

NS_ASSUME_NONNULL_BEGIN

/// 书籍第一章第一页的封面
@interface WXYZ_BookFrontCoverView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                bookModel:(WXYZ_ProductionModel *)bookModel
                readerSetting:(WXYZ_ReaderSettingHelper *)readerSetting;

@end

NS_ASSUME_NONNULL_END
