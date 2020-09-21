//
//  WXYZ_PublicADStyleTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2019/6/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_PublicADStyleTableViewCell : WXYZ_BasicTableViewCell

- (void)setAdModel:(WXYZ_ADModel * _Nonnull)adModel refresh:(BOOL)refresh;

@property (nonatomic, weak) UITableView *mainTableView;

@end

NS_ASSUME_NONNULL_END
