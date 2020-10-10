//
//  WXYZ_UserInfoManager.m
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//



#import "NSObject+Utils.h"

@implementation WXYZ_UserInfoManager

#pragma mark - Public
static WXYZ_UserInfoManager * _userInfoInstance;
+ (instancetype)shareInstance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userInfoInstance = [super allocWithZone:zone];
        _userInfoInstance = [self dynamicInit];
    });
    return _userInfoInstance;
}

- (instancetype)init {
    if ([[NSFileManager defaultManager] fileExistsAtPath:WXYZ_UserInfoManager.userInfoPath] && kObjectIsEmpty(_userInfoInstance.token)) {
        _userInfoInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:WXYZ_UserInfoManager.userInfoPath];
    }
    
    NSString *line_data = [[NSUserDefaults standardUserDefaults]objectForKey:@"line_data"];
    if (line_data != nil && line_data.length > 0) {
        _lineData = [line_data integerValue];
    }
    
    NSString *clear_data = [[NSUserDefaults standardUserDefaults]objectForKey:@"clear_data"];
    if (clear_data != nil && clear_data.length > 0) {
        _clearData = [clear_data integerValue];
    }
    
    
    return _userInfoInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _userInfoInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _userInfoInstance;
}

+ (BOOL)isLogin {
    return !kObjectIsEmpty([[self shareInstance] token]);
}

static NSDictionary<NSString *, NSString *> *_property;
+ (instancetype)logout {
    [self dynamicInit];
    // 删除本地用户信息
    [[NSFileManager defaultManager] removeItemAtPath:self.userInfoPath error:nil];
    return _userInfoInstance;
}


#pragma mark - Private
+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"token" : @"user_token",
        @"vip"   : @"is_vip",
        @"masterRemain" : @"goldRemain",
        @"subRemain" : @"silverRemain",
        @"totalRemain" : @"remain"
    };
}

/// 动态初始化Model所有值，避免Null、nil
+ (instancetype)dynamicInit {
    if (_userInfoInstance == nil) _userInfoInstance = [self shareInstance];
    // 动态获取属性列表，遍历属性并初始化.
    _property = _property ?: [self propertyDict];
    [_property enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        SEL sel = [WXYZ_UtilsHelper createSetterWithPropertyName:key];
        if ([_userInfoInstance respondsToSelector:sel]) {
            Class t_class = NSClassFromString(value);
            [_userInfoInstance performSelectorOnMainThread:sel withObject:[t_class new] waitUntilDone:[NSThread isMainThread]];
        }
    }];
    return _userInfoInstance;
}

+ (instancetype)updateWithDict:(NSDictionary *)dict {
    if (_userInfoInstance == nil) _userInfoInstance = [self shareInstance];
    // 动态获取属性列表，遍历并更新属性
    _property = _property ?: [self propertyDict];
    [_property enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        SEL sel = [WXYZ_UtilsHelper createSetterWithPropertyName:key];// 获取属性的set方法
        if ([_userInfoInstance respondsToSelector:sel]) {
            Class t_class = NSClassFromString(value);
            NSDictionary *t_dict = [self modelCustomPropertyMapper];
            id t_name = t_dict[key];
            if ([t_name isKindOfClass:NSArray.class]) {
                for (NSString *obj in t_name) {
                    [self updateWithSel:sel obj:dict[obj] class:t_class];
                }
            } else if ([t_name isKindOfClass:NSString.class]) {
                [self updateWithSel:sel obj:dict[t_name] class:t_class];
            } else {
                [self updateWithSel:sel obj:dict[key] class:t_class];
            }
        }
    }];
    // 删除本地用户信息
    [[NSFileManager defaultManager] removeItemAtPath:self.userInfoPath error:nil];
    // 保存用户信息到本地
    [NSKeyedArchiver archiveRootObject:_userInfoInstance toFile:self.userInfoPath];
    
    return _userInfoInstance;
}

+ (void)updateWithSel:(SEL)sel obj:(id)obj class:(Class)class {
    if (!obj) return;

    if ([obj isKindOfClass:NSNumber.class]) {
        NSNumber *number = obj;
        ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)_userInfoInstance, sel, (uint64_t)number.longLongValue);
        return;
    }
    
    [_userInfoInstance performSelectorOnMainThread:sel withObject:obj waitUntilDone:[NSThread isMainThread]];
}

+ (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self.class selector:@selector(logout) name:Notification_Logout object:nil];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    _userInfoInstance = [super modelWithDictionary:dictionary];
    [NSKeyedArchiver archiveRootObject:_userInfoInstance toFile:self.userInfoPath];
    return _userInfoInstance;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self modelInitWithCoder:coder];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [self modelEncodeWithCoder:coder];
}

+ (NSString *)userInfoPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"userInfo"];
}


- (void)setLineData:(NSInteger)lineData {
    _lineData = lineData;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%li",lineData] forKey:@"line_data"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setClearData:(NSInteger)clearData {
    _clearData = clearData;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%li",clearData] forKey:@"clear_data"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
