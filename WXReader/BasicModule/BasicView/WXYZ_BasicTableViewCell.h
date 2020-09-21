//
//  WXYZ_BasicTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/12/23.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BasicTableViewCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *cellIndexPath;

@property (nonatomic, assign) BOOL hiddenEndLine;

@property (nonatomic, weak) UIView *cellLine;

@property (nonatomic, assign) WXYZ_ProductionType productionType;

- (void)createSubviews;

@end

NS_ASSUME_NONNULL_END
