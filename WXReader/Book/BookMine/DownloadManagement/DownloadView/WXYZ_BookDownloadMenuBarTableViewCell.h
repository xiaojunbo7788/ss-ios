//
//  WXYZ_BookDownloadMenuBarTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/4/1.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_BookDownloadTaskListModel.h"
#import "WXYZ_BookDownloadManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookDownloadMenuBarTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_DownloadTaskModel *optionModel;

@property (nonatomic, assign) WXYZ_DownloadMissionState missionState;

@property (nonatomic, assign) NSInteger book_id;

- (void)startDownloadLoading;

@end

NS_ASSUME_NONNULL_END
