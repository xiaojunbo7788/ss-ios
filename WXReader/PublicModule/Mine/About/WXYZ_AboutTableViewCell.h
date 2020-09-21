//
//  WXYZ_AboutTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2018/10/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_AboutModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_AboutTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, strong) WXYZ_ContactInfoModel *contactInfoModel;

@end

NS_ASSUME_NONNULL_END
