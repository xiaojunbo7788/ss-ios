//
//  WXYZ_ComicReaderCollectionCell.h
//  WXReader
//
//  Created by Andrew on 2019/6/3.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_ComicReaderCollectionCellCellDelegate <NSObject>

- (void)refreshCurrentCell:(int)row;

@end


@interface WXYZ_ComicReaderCollectionCell : UICollectionViewCell

@property (nonatomic, weak) id<WXYZ_ComicReaderCollectionCellCellDelegate>delegate;

@property (nonatomic, assign) int localRow;

@property (nonatomic, strong) WXYZ_ImageListModel *imageModel;

@property (nonatomic, assign) NSInteger comic_id;

@property (nonatomic, assign) NSInteger chapter_id;

@property (nonatomic, assign) NSInteger chapter_update_time;

@property (nonatomic, assign) int selModel;

@end

NS_ASSUME_NONNULL_END
