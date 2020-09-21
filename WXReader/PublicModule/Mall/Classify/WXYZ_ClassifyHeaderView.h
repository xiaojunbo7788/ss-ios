//
//  WXYZ_ClassifyHeaderView.h
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_ClassifyModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SearchBoxSelectBlock)(NSString *field, NSString *value);

@interface WXYZ_ClassifyHeaderView : UIView

@property (nonatomic, strong) NSArray <WXYZ_SearchBoxModel *>*search_box;

@property (nonatomic, copy) SearchBoxSelectBlock searchBoxSelectBlock;

@end

NS_ASSUME_NONNULL_END
