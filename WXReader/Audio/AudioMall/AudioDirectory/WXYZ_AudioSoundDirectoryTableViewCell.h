//
//  WXYZ_AudioSoundDirectoryTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/3/12.
//  Copyright © 2020 Andrew. All rights reserved.
//
#import "WXYZ_DownloadManagerEnumProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioSoundDirectoryTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, copy) void (^downloadChapterBlock)(NSInteger audio_id, NSInteger chapter_id, NSIndexPath *cellIndexPath);

@property (nonatomic, strong) WXYZ_ProductionChapterModel *chapterListModel;

@property (nonatomic, assign) WXYZ_ProductionDownloadState cellDownloadState;

@end

NS_ASSUME_NONNULL_END
