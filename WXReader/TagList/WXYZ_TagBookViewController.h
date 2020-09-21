//
//  WXYZ_ClassifyViewController.h
//  WXReader
//
//  Created by Andrew on 2019/6/17.
//  Copyright © 2019 Andrew. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_TagBookViewController : WXYZ_BasicViewController

//0 作者、1、标签、2、分类、3、汉化组、4、原著
@property (nonatomic, assign) int classType;
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *tagTitle;

@end

NS_ASSUME_NONNULL_END
