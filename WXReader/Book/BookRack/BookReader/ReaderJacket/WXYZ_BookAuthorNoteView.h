//
//  WXYZ_BookAuthorNoteView.h
//  WXReader
//
//  Created by LL on 2020/6/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYZ_BookAuthorNoteModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_BookAuthorNoteView : UIView

- (instancetype)initWithFrame:(CGRect)frame notoModel:(WXYZ_BookAuthorNoteModel *)noteModel;

@property (nonatomic, assign) CGFloat noteHeight;

@property (nonatomic, assign) CGFloat spacing;

@end


@interface WXYZ_BookAuthorNoteModel : NSObject

/// 作者寄语
@property (nonatomic, copy) NSString *author_note;

/// 评论数
@property (nonatomic, copy) NSString *comment_num;

/// 月票数
@property (nonatomic, copy) NSString *ticket_num;

/// 打赏数
@property (nonatomic, copy) NSString *reward_num;

@property (nonatomic, assign) NSInteger author_id;

@property (nonatomic, copy) NSString *author_name;

@property (nonatomic, copy) NSString *author_avatar;

@end

NS_ASSUME_NONNULL_END
