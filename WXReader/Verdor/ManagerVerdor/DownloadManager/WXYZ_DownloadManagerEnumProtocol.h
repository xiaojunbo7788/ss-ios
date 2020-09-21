//
//  WXYZ_DownloadManagerEnumProtocol.h
//  WXReader
//
//  Created by Andrew on 2020/7/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_DownloadChapterState) {
    WXYZ_DownloadStateChapterDownloadNormal,    // 章节下载未开始
    WXYZ_DownloadStateChapterDownloadStart,     // 章节下载开始
    WXYZ_DownloadStateChapterDownloadFinished,  // 章节下载完成
    WXYZ_DownloadStateChapterDownloadFail       // 章节下载失败
};

typedef NS_ENUM(NSUInteger, WXYZ_DownloadMissionState) {
    WXYZ_DownloadStateMissionShouldPay,         // 任务失败需要支付
    WXYZ_DownloadStateMissionNormal,            // 任务未开始
    WXYZ_DownloadStateMissionStart,             // 任务开始
    WXYZ_DownloadStateMissionFinished,          // 任务完成
    WXYZ_DownloadStateMissionFail               // 任务失败
};

typedef NS_ENUM(NSUInteger, WXYZ_ProductionDownloadState) {
    WXYZ_ProductionDownloadStateNormal      = 0,    // 普通状态
    WXYZ_ProductionDownloadStateDownloading = 1,    // 下载中
    WXYZ_ProductionDownloadStateDownloaded  = 2,    // 已下载
    WXYZ_ProductionDownloadStateFail        = 3,    // 失败
    WXYZ_ProductionDownloadStateSelected    = 4     // 选中
};

#define identify_downloading @"id_downloading"

#define identify_fail @"id_fail"

@protocol WXYZ_DownloadManagerEnumProtocol <NSObject>

@end

NS_ASSUME_NONNULL_END
