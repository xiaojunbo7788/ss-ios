//
//  WXYZ_SearchView.h
//  WXReader
//
//  Created by Andrew on 2019/5/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_SearchView : UIButton

@property (nonatomic, strong) NSArray *placeholderArray;

@property (nonatomic, strong) NSString *currentPlaceholder;

@property (nonatomic, assign) BOOL searchViewDarkColor;

@end

NS_ASSUME_NONNULL_END
