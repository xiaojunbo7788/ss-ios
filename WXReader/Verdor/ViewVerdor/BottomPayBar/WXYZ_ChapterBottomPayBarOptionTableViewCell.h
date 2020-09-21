//
//  WXYZ_ChapterBottomPayBarOptionTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"
#import "WXYZ_ChapterPayBarModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ChapterBottomPayBarOptionTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, copy) void (^payOptionClickBlock)(WXYZ_ChapterPayBarOptionModel *chapterOptionModel, NSInteger selectIndex);

@property (nonatomic, strong) NSArray <WXYZ_ChapterPayBarOptionModel *> *pay_options;

@end

NS_ASSUME_NONNULL_END
