//
//  WXYZ_ComicInfoListStringTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/8/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicInfoListStringTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, copy) NSString *leftTitleString;

@property (nonatomic, copy) NSString *rightTitleString;

@end

NS_ASSUME_NONNULL_END
