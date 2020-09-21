//
//  WXYZ_AudioDownloadTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"
#import "WXYZ_DownloadManagerEnumProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioDownloadTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_ProductionChapterModel *chapterModel;

// 是否是缓存状态
@property (nonatomic, assign) BOOL isCacheState;

@property (nonatomic, assign) WXYZ_ProductionDownloadState cellDownloadState;

@end

NS_ASSUME_NONNULL_END
