//
//  WXYZ_BookMallDetailDirectoryTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/8/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CatalogueButtonClickBlock)(void);

@interface WXYZ_BookMallDetailDirectoryTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, copy) CatalogueButtonClickBlock catalogueButtonClickBlock;

@property (nonatomic, strong) WXYZ_ProductionModel *bookModel;

@end

NS_ASSUME_NONNULL_END
