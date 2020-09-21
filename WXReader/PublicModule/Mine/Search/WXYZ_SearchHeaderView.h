//
//  WXYZ_SearchHeaderView.h
//  WXReader
//
//  Created by Andrew on 2018/7/5.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HotWorkClickBlock)(NSString *hotWord);

@protocol WXYZ_SearchHeaderViewDelegate <NSObject>

- (void)selectTagBy:(NSDictionary *)data;
- (void)selectMoreTag;

@end


@interface WXYZ_SearchHeaderView : UIView

@property (nonatomic, weak) id<WXYZ_SearchHeaderViewDelegate>delegate;
@property (nonatomic, strong) NSArray *hotWordArray;

@property (nonatomic, copy) HotWorkClickBlock hotWorkClickBlock;

- (void)showTagArray:(NSArray *)tagArray;

- (void)setSmallFrame;

- (void)setNormalFrame;

@end
