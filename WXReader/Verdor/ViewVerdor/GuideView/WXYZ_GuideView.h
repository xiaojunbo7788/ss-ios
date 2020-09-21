//
//  WXYZ_GuideView.h
//  WXReader
//
//  Created by Andrew on 2020/5/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXYZ_GuideType) {
    WXYZ_GuideTypeBookReader
};

@interface WXYZ_GuideView : UIView

- (instancetype)initWithGuideType:(WXYZ_GuideType)guideType;

- (void)hidden;

@end

NS_ASSUME_NONNULL_END
