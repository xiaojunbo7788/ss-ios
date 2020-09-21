//
//  WXYZ_DownloadViewController.h
//  WXReader
//
//  Created by Andrew on 2020/7/24.
//  Copyright © 2020 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

//typedef NS_ENUM(NSUInteger, WXYZ_DownloadCellState) {
//    WXYZ_DownloadCellStateNormal,       // 未下载\未选中
//    WXYZ_DownloadCellStateSelect,       // 选中
//    WXYZ_DownloadCellStateDownloaded    // 已下载
//};

// 仅用于处理数据
@interface WXYZ_DownloadViewController : WXYZ_BasicViewController

// 选择存储器
@property (nonatomic, strong) NSMutableDictionary *selectSourceDictionary;

// index合集
@property (nonatomic, strong) NSMutableDictionary *cellIndexDictionary;

// 重置选择存储器
- (void)resetSelectSourceDicWithDataSourceArray:(NSArray <WXYZ_ProductionChapterModel *>*)dataSourceArray productionType:(WXYZ_ProductionType)productionType;

@end

NS_ASSUME_NONNULL_END
