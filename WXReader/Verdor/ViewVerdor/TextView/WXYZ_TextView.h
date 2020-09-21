//
//  DPTextView.h
//  WXReader
//
//  Created by Andrew on 2018/6/27.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WXYZ_TextViewDelegate <NSObject>

@optional

- (void)textViewDidChange:(NSString *)text;

@end

@interface WXYZ_TextView : UIView

@property (nonatomic, assign) NSUInteger maxWordCount;

@property (nonatomic, copy, readonly) NSString *text;

@property (nonatomic, weak) id<WXYZ_TextViewDelegate> delegate;

- (void)resetPlaceholderText:(NSString *)placeholderText;

@end
