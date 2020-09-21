//
//  WXYZ_ComicReaderDownloadCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/6/8.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_DownloadManagerEnumProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicReaderDownloadCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_ProductionChapterModel *chapterModel;

@property (nonatomic, assign) WXYZ_ProductionDownloadState cellDownloadState;

@end

NS_ASSUME_NONNULL_END
