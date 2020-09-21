//
//  WXYZ_ComicInfoListTableViewCell.h
//  WXReader
//
//  Created by Andrew on 2020/8/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BasicTableViewCell.h"

@protocol WXYZ_ComicInfoListTableViewCellDelegate <NSObject>

- (void)gotoTagList:(int)classType withTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_ComicInfoListTableViewCell : WXYZ_BasicTableViewCell

@property (nonatomic, weak) id<WXYZ_ComicInfoListTableViewCellDelegate>delegate;
@property (nonatomic, copy) NSString *leftTitleString;

@property (nonatomic, strong) NSArray *detailArray;

@end

NS_ASSUME_NONNULL_END
