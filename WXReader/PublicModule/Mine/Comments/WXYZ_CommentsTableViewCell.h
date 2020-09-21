//
//  WXYZ_CommentsTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/5/27.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit.h>

@interface WXYZ_CommentsTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_CommentsDetailModel *commentModel;

/// 预览列表分割线和正常列表不一样
- (void)setIsPreview:(BOOL)isPreview lastRow:(BOOL)lastRow;

@end
