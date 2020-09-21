//
//  WXYZ_RackCenterCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/6/28.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_ProductionModel;

@interface WXYZ_RackCenterCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_ProductionModel *productionModel;

@property (nonatomic, assign) BOOL bookSeleced;

@property (nonatomic, strong) WXYZ_ProductionCoverView *bookImageView;

@property (nonatomic, strong) NSString *badgeNum;

@property (nonatomic, assign) BOOL startEditing;

@end
