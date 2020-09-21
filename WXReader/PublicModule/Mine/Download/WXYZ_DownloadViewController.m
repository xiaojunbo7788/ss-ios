//
//  WXYZ_DownloadViewController.m
//  WXReader
//
//  Created by Andrew on 2020/7/24.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_DownloadViewController.h"

#import "WXYZ_ComicDownloadManager.h"
#import "WXYZ_AudioDownloadManager.h"

@interface WXYZ_DownloadViewController ()

@end

@implementation WXYZ_DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 重置选择存储器
- (void)resetSelectSourceDicWithDataSourceArray:(NSArray <WXYZ_ProductionChapterModel *>*)dataSourceArray productionType:(WXYZ_ProductionType)productionType
{
    // 刷新数据后,已选择章节的恢复设置为已选择
    NSMutableDictionary *t_selectDictionary = [self.selectSourceDictionary mutableCopy];
    
    [self.selectSourceDictionary removeAllObjects];
    
    // index合集
    [self.cellIndexDictionary removeAllObjects];
    
    NSMutableArray *t_arr = [dataSourceArray mutableCopy];
    
    for (int i = 0; i < t_arr.count; i++) {
        WXYZ_ProductionChapterModel *t_chapterModel = [t_arr objectAtIndex:i];
        if (productionType == WXYZ_ProductionTypeComic) {
            
            WXYZ_ProductionDownloadState state = [[WXYZ_ComicDownloadManager sharedManager] getChapterDownloadStateWithProduction_id:t_chapterModel.production_id chapter_id:t_chapterModel.chapter_id];
            [self.selectSourceDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:state] forKey:[WXYZ_UtilsHelper formatStringWithInteger:t_chapterModel.chapter_id]];
            
        } else if (productionType == WXYZ_ProductionTypeAudio) {
            WXYZ_ProductionDownloadState state = [[WXYZ_AudioDownloadManager sharedManager] getChapterDownloadStateWithProduction_id:t_chapterModel.production_id chapter_id:t_chapterModel.chapter_id];
            [self.selectSourceDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:state] forKey:[WXYZ_UtilsHelper formatStringWithInteger:t_chapterModel.chapter_id]];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.cellIndexDictionary setObject:indexPath forKey:[WXYZ_UtilsHelper formatStringWithInteger:t_chapterModel.chapter_id]];
    }
    
    
    for (NSString *t_key in t_selectDictionary.allKeys) {
        if ([[t_selectDictionary objectForKey:t_key] integerValue] == WXYZ_ProductionDownloadStateSelected) {
            [self.selectSourceDictionary setObject:[WXYZ_UtilsHelper formatStringWithInteger:WXYZ_ProductionDownloadStateSelected] forKey:t_key];
        }
    }
}

- (NSMutableDictionary *)selectSourceDictionary
{
    if (!_selectSourceDictionary) {
        _selectSourceDictionary = [NSMutableDictionary dictionary];
    }
    return _selectSourceDictionary;
}

- (NSMutableDictionary *)cellIndexDictionary
{
    if (!_cellIndexDictionary) {
        _cellIndexDictionary = [NSMutableDictionary dictionary];
    }
    return _cellIndexDictionary;
}

@end
