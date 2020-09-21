//
//  WXYZ_TagTableViewCell.h
//  WXReader
//
//  Created by geng on 2020/9/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WXYZ_TagTableViewCellDelegate <NSObject>

- (void)selectTag:(int)index;

@end


@interface WXYZ_TagTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, weak) id<WXYZ_TagTableViewCellDelegate>delegate;
@property (nonatomic, strong) NSArray *detailArray;

@end

NS_ASSUME_NONNULL_END
