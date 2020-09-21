//
//  WXYZ_UserDataTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/5/30.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"

@class WXYZ_UserDataListModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_UserDataTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_UserDataListModel *cellModel;

@end

NS_ASSUME_NONNULL_END
