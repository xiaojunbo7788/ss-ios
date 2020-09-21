//
//  WXYZ_ProductionListTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_TagView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ProductionListTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_ProductionModel *listModel;

/// 是否来自榜单
@property (nonatomic, assign) BOOL isRankList;

// 书籍图片
@property (nonatomic, strong) WXYZ_ProductionCoverView *bookImageView;

@property (nonatomic, strong) UILabel *bookTitleLabel;

@property (nonatomic, strong) YYLabel *bookIntroductionLabel;

@property (nonatomic, strong) UILabel *authorLabel;
    
@property (nonatomic, strong) WXYZ_TagView *tagView;

@end

NS_ASSUME_NONNULL_END
