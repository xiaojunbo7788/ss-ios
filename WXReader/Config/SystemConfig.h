//
//  SystemConfig.h
//  WXReader
//
//  Created by Andrew on 2018/5/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#ifndef SystemConfig_h
#define SystemConfig_h

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define SS(strongSelf)__strong __typeof(weakSelf)strongSelf = weakSelf;

//  AppDelegate
#define KAppDelegate ((AppDelegate*)kRCodeSync([UIApplication sharedApplication].delegate))

// App版本
#define App_Ver [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]

// App名称
#define App_Name [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]]

// 系统信息文件名称
#define System_Info_Path @"systemInfo"

// 用户信息文件名称
#define User_Info_Path @"userInfo"

// 常用宏定义
#define kNotification [NSNotificationCenter defaultCenter]

//系统版本
#define is_ios7  [[[UIDevice currentDevice]systemVersion] floatValue] >= 7
#define is_ios8  [[[UIDevice currentDevice]systemVersion] floatValue] >= 8
#define is_ios9  [[[UIDevice currentDevice] systemVersion] floatValue] >= 9
#define is_ios10 [[[UIDevice currentDevice] systemVersion] floatValue] >= 10
#define is_ios11 [[[UIDevice currentDevice] systemVersion] floatValue] >= 11
#define is_ios13 [[[UIDevice currentDevice] systemVersion] floatValue] >= 13

//手机型号
#define is_iPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define is_iPhone4 ([UIScreen mainScreen].bounds.size.height == 480)
#define is_iPhone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define is_iPhone6 ([UIScreen mainScreen].bounds.size.height == 667)
#define is_iPhone6P ([UIScreen mainScreen].bounds.size.height == 1104)
#define is_iPhoneX ((([[UIScreen mainScreen] bounds].size.width == 375.0 && \
[[UIScreen mainScreen] bounds].size.height == 812.0) || \
([[UIScreen mainScreen] bounds].size.width == 414.0 && \
[[UIScreen mainScreen] bounds].size.height == 896.0)) ? YES : NO)
#define is_iPhoneX_Max ((([[UIScreen mainScreen] bounds].size.width == 414.0 && \
[[UIScreen mainScreen] bounds].size.height == 896.0)) ? YES : NO)

//主窗口
#define kMainWindow (is_ios13?[[[UIApplication sharedApplication] windows] objectAtIndex:0]:[[UIApplication sharedApplication] keyWindow])

// 审核状态
#define isMagicState [WXYZ_UtilsHelper isInSafetyPeriod]

// 比对ErrorNo
#define Compare_Json_isEqualTo(A,B) (A == B)

#if __LP64__
#define MZNSI @"ld"
#define MZNSU @"lu"
#else
#define MZNSI @"d"
#define MZNSU @"u"
#endif //__LP64__

#define interface_singleton \
+ (instancetype)sharedManager;
 
 
// @implementation
#define implementation_singleton(className) \
static className *_instance_##className;\
+ (instancetype)allocWithZone:(struct _NSZone *)zone{\
static dispatch_once_t once_token_##className;\
dispatch_once(&once_token_##className, ^{\
_instance_##className = [super allocWithZone:zone];\
});\
return _instance_##className;\
}\
+ (instancetype)sharedManager{\
static dispatch_once_t once_token_##className;\
dispatch_once(&once_token_##className, ^{\
_instance_##className = [[self alloc] init];\
});\
return _instance_##className;\
}\
- (id)copyWithZone:(NSZone *)zone{\
return _instance_##className;\
}

// ???: 在主线程中执行一段代码并返回对象(返回和接收值都是id类型)
#define kRCodeSync(x) ({\
    id __block temp;\
    if ([NSThread isMainThread]) {\
        temp = x;\
    } else {\
        dispatch_semaphore_t signal = dispatch_semaphore_create(0);\
        dispatch_async(dispatch_get_main_queue(), ^{\
            temp = x;\
            dispatch_semaphore_signal(signal);\
        });\
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);\
    }\
    temp;\
})

// ???: 在主线程中执行一段代码
#define kCodeSync(x) ({\
    if ([NSThread isMainThread]) {\
        x;\
    } else {\
        dispatch_semaphore_t signal = dispatch_semaphore_create(0);\
        dispatch_async(dispatch_get_main_queue(), ^{\
            x;\
            dispatch_semaphore_signal(signal);\
        });\
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);\
    }\
})

#endif /* SystemConfig_h */
