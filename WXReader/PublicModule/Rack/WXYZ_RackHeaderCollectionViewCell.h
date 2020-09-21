//
//  WXYZ_RackHeaderCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/6/13.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_RackHeaderCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_ProductionModel *productionModel;

@property (nonatomic, assign) WXYZ_ProductionType productionType;

@end

NS_ASSUME_NONNULL_END
