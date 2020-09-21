//
//  UUID.m
//
//  Created by Andrew on 2017/8/5.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "UUID.h"
#import "KeyChainStore.h"

#define UUID_KEY(bunid) [NSString stringWithFormat:@"cn.property.uuidkey%@",bunid]
#define Pasteboard(bunid) [NSString stringWithFormat:@"cn.property.PublicPasteBord%@",bunid]

@implementation UUID
+ (NSString *)getUUID
{   
    NSString *bunid = [[NSBundle mainBundle]bundleIdentifier];
    NSString *strUUID;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    strUUID = [userDefault objectForKey:UUID_KEY(bunid)];
    if (!strUUID) {
        UIPasteboard *pp = [UIPasteboard generalPasteboard];
        NSData *data = [pp valueForPasteboardType:Pasteboard(bunid)];
        strUUID = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!strUUID || [strUUID isEqualToString:@""]) {
            strUUID = (NSString *)[KeyChainStore load:UUID_KEY(bunid)];
            if (strUUID) {
                [userDefault setObject:strUUID forKey:UUID_KEY(bunid)];
                [userDefault synchronize];
            }
        } else {
            [userDefault setObject:strUUID forKey:UUID_KEY(bunid)];
            [userDefault synchronize];
        
        }
    }
    
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""] || !strUUID) {
        
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        [KeyChainStore save:UUID_KEY(bunid) data:strUUID];
        [userDefault setObject:strUUID forKey:UUID_KEY(bunid)];
        [userDefault synchronize];
        UIPasteboard *p = [UIPasteboard generalPasteboard];
        [p setValue:strUUID forPasteboardType:Pasteboard(bunid)];
        
        CFRelease(uuidRef);

    }
    return strUUID;
}

@end
