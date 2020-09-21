//
//  WXYZ_MemberPrivilegeTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/4/21.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"
#import "WXYZ_MemeberModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_MemberPrivilegeTableViewCell : WXYZ_BasicTableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<WXYZ_PrivilegeModel *> *privilege;

@end

NS_ASSUME_NONNULL_END
