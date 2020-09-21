//
//  DPSearchBar.h
//  WXReader
//
//  Created by Andrew on 2018/7/5.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPSearchBarDelegate <NSObject>

@optional

- (void)cancelButtonClicked;

- (void)searchButtonClickedWithSearchText:(NSString *)searchText;

- (void)searchBarCleanText;

@end

@interface WXYZ_SearchBar : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id <DPSearchBarDelegate> delegate;

@property (nonatomic, copy) NSString *placeholderText;

@property (nonatomic, copy) NSString *searchText;

- (void)searchBarResignFirstResponder;

@end
