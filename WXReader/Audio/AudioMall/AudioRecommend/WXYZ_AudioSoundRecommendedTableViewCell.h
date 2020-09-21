//
//  WXYZ_AudioSoundRecommendedTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/7/8.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ProductionListTableViewCell.h"

@class WXYZ_AudioSoundPlayPageModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AudioSoundRecommendedTableViewCell : WXYZ_ProductionListTableViewCell

@property (nonatomic, copy) void(^clickBlock)(NSInteger production_id);

- (void)setListModel:(WXYZ_AudioSoundPlayPageModel *)listModel;

@end

NS_ASSUME_NONNULL_END
