//
//  WXYZ_UserCenterModel.m
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_UserCenterModel.h"

@interface WXYZ_UserCenterModel ()


@end

@implementation WXYZ_UserCenterModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"vip" : @"is_vip",
        @"masterUnit" : @"unit",
        @"masterRemain" : @"goldRemain",
        @"subRemain" : @"silverRemain"
    };
}


- (id)mutableCopyWithZone:(NSZone *)zone {
    
    WXYZ_UserCenterModel *model = [[[self class] allocWithZone:zone] init];
    model.nickname = _nickname;
    
    model.avatar = _avatar;
    model.user_token = _user_token;
    model.masterUnit = _masterUnit;
    model.masterRemain = _masterRemain;
    model.subUnit = _subUnit;
    model.nickname = _nickname;
    model.subRemain = _subRemain;
    model.ticketRemain = _ticketRemain;
    model.vip = _vip;
    model.mobile = _mobile;
    model.uid = _uid;
    model.gender = _gender;
    model.panel_list = _panel_list;
    return model;
}


+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    WXYZ_UserCenterModel *t_model = [super modelWithDictionary:dictionary];
    NSMutableArray<NSArray <WXYZ_UserCenterListModel *> *> *t_list = [NSMutableArray array];
    for (NSArray *obj in t_model.panel_list) {
        NSArray<WXYZ_UserCenterListModel *> *arr = [NSArray modelArrayWithClass:WXYZ_UserCenterListModel.class json:obj];
        [t_list addObject:arr];
    }
    t_model.panel_list = t_list;
    return t_model;
}

//TODO:?????
- (void)setPanel_list:(NSArray<NSArray<WXYZ_UserCenterListModel *> *> *)panel_list {
    _panel_list = panel_list;
    

    if (_panel_list != nil && _panel_list.count > 0) {
        if (WXYZ_UserInfoManager.isLogin) {
            NSArray *collectArray = [self collectArray];
            _panelNewList = [panel_list mutableCopy];
            [_panelNewList insertObject:collectArray atIndex:1];
        } else {
            _panelNewList = [panel_list mutableCopy];
        }
    }
}

- (NSArray *)collectArray {
    WXYZ_UserCenterListModel *model1 = [[WXYZ_UserCenterListModel alloc] init];
    model1.title  = @"喜欢的作者";
    model1.action = @"author";
    model1.enable = true;
    model1.desc_color = @"#39383C";
    model1.title_color = @"#39383C";
    model1.icon = @"http://backend.songshucangku.com/icon/user/13.png";
    
    WXYZ_UserCenterListModel *model2 = [[WXYZ_UserCenterListModel alloc] init];
    model2.title  = @"喜欢的原著";
    model2.action = @"orginal";
    model2.enable = true;
    model2.desc_color = @"#39383C";
    model2.title_color = @"#39383C";
    model2.icon = @"http://backend.songshucangku.com/icon/user/14.png";
    
    WXYZ_UserCenterListModel *model3 = [[WXYZ_UserCenterListModel alloc] init];
    model3.title  = @"喜欢的汉化组";
    model3.action = @"hanhua";
    model3.enable = true;
    model3.desc_color = @"#39383C";
    model3.title_color = @"#39383C";
    model3.icon = @"http://backend.songshucangku.com/icon/user/12.png";
    return @[model1,model2,model3];
}

@end


@implementation WXYZ_UserCenterListModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"enable" : @"is_click"
    };
}



@end
