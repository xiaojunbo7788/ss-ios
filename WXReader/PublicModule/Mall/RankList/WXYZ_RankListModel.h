//
//  WXYZ_RankListModel.h
//  WXReader
//
//  Created by Andrew on 2018/6/14.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXYZ_RankListModel : NSObject

@property (nonatomic, copy) NSString *rank_type;    //排行榜类型
@property (nonatomic, copy) NSString *list_name;    //榜单名
@property (nonatomic, copy) NSString *rankDescription;  //榜单简介
@property (nonatomic, strong) NSArray <NSString *>*icon;         //榜单图标

@end
