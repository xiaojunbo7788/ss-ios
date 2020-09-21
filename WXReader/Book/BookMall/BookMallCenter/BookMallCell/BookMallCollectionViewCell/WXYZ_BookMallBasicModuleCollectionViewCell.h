//
//  WXYZ_BookMallBasicModuleCollectionViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/6/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookMallBasicModuleCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) WXYZ_ProductionCoverView *productionImageView;

@property (nonatomic, strong) UILabel *bookTitleLabel;

@property (nonatomic, strong) UILabel *bookSubTitleLabel;

@property (nonatomic, strong) UIView *cellLine;

@property (nonatomic, strong) WXYZ_ProductionModel *labelListModel;

@property (nonatomic, strong) NSIndexPath *cellIndexPath;

@property (nonatomic, assign) BOOL hiddenEndLine;

- (void)createSubviews;

@end

NS_ASSUME_NONNULL_END
