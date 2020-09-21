//
//  WXYZ_ComicDirectoryListTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/5/30.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ProductionReadRecordManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicDirectoryListTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_ProductionChapterModel *chapterModel;

@end

NS_ASSUME_NONNULL_END
