//
//  WXYZ_ComicReaderAdapterCollectionViewCell.h
//  WXReader
//
//  Created by geng on 2020/9/28.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicReaderAdapterCollectionViewCell : UITableViewCell
@property (nonatomic, assign) NSInteger comic_id;
@property (nonatomic, assign) NSInteger chapter_id;
@property (nonatomic, assign) NSInteger chapter_update_time;
@property (nonatomic, strong) UICollectionView *collectionView;
- (void)reloadDataByArray:(NSMutableArray *)dataArray;
@end

NS_ASSUME_NONNULL_END
