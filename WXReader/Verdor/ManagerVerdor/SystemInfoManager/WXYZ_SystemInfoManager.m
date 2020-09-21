//
//  WXYZ_SystemInfoModel.m
//  WXReader
//
//  Created by LL on 2020/6/5.
//  Copyright © 2020 Andrew. All rights reserved.
//



@implementation WXYZ_SystemInfoManager

#pragma mark - Public

static NSString *_taskReadProductionId = nil;
+ (void)setTaskReadProductionId:(NSString *)taskReadProductionId
{
    if (!taskReadProductionId) return;
    _taskReadProductionId = taskReadProductionId;
    [self.systemDict setObject:taskReadProductionId forKey:KEY_PATH(self, taskReadProductionId)];
    [self.systemDict writeToFile:self.systemPath atomically:YES];
}

+ (NSString *)taskReadProductionId
{
    return _taskReadProductionId ?: [self.systemDict objectForKey:@"taskReadProductionId"]?:@"";
}

static NSString *_masterUnit = nil;
+ (void)setMasterUnit:(NSString *)masterUnit {
    if (!masterUnit) return;
    _masterUnit = masterUnit;
    [self.systemDict setObject:masterUnit forKey:KEY_PATH(self, masterUnit)];
    [self.systemDict writeToFile:self.systemPath atomically:YES];
}

+ (NSString *)masterUnit {
    return _masterUnit ?: [self.systemDict objectForKey:@"masterUnit"] ?: Main_Unit_Name;
}

static NSString *_subUnit = nil;
+ (void)setSubUnit:(NSString *)subUnit {
    if (!subUnit) return;
    _subUnit = subUnit;
    [self.systemDict setObject:subUnit forKey:KEY_PATH(self, subUnit)];
    [self.systemDict writeToFile:self.systemPath atomically:YES];
}

+ (NSString *)subUnit {
    return _subUnit ?: [self.systemDict objectForKey:@"subUnit"] ?: Sub_Unit_Name;
}

static NSInteger _sexChannel = 0;
+ (void)setSexChannel:(NSInteger)sexChannel {
    _sexChannel = sexChannel;
    [self.systemDict setObject:[NSString stringWithFormat:@"%zd", sexChannel] forKey:KEY_PATH(self, sexChannel)];
    [self.systemDict writeToFile:self.systemPath atomically:YES];
}

+ (NSInteger)sexChannel {
    return _sexChannel ?: [[self.systemDict objectForKey:@"sexChannel"] integerValue] ?: 1;
}

static NSString *_magicStatus = nil;
+ (void)setMagicStatus:(NSString *)magicStatus {
    _magicStatus = magicStatus;
    [self.systemDict setObject:magicStatus forKey:KEY_PATH(self, magicStatus)];
    [self.systemDict writeToFile:self.systemPath atomically:YES];
}

+ (NSString *)magicStatus {
    return _magicStatus ?: [self.systemDict objectForKey:@"magicStatus"];
}

static BOOL _agreementAllow = NO;
+ (void)setAgreementAllow:(BOOL)agreementAllow {
    _agreementAllow = agreementAllow;
    [self.systemDict setObject:[NSString stringWithFormat:@"%d", agreementAllow] forKey:KEY_PATH(self, agreementAllow)];
    [self.systemDict writeToFile:self.systemPath atomically:YES];
}

+ (BOOL)agreementAllow {
    return _agreementAllow ?: [[self.systemDict objectForKey:@"agreementAllow"] boolValue];
}

static NSString *_firstGenderSelecte= nil;
+ (void)setFirstGenderSelecte:(NSString *)firstGenderSelecte {
    _firstGenderSelecte = firstGenderSelecte;
    [self.systemDict setValue:firstGenderSelecte forKey:KEY_PATH(self, firstGenderSelecte)];
    [self.systemDict writeToFile:self.systemPath atomically:YES];
}

+ (NSString *)firstGenderSelecte {
    return _firstGenderSelecte ?: [self.systemDict objectForKey:@"firstGenderSelecte"];
}

static NSMutableDictionary *_systemDict = nil;
+ (NSMutableDictionary *)systemDict {
    if (!_systemDict) {
        _systemDict = [NSMutableDictionary dictionaryWithContentsOfFile:self.systemPath];
        if (!_systemDict) {
            _systemDict = [NSMutableDictionary dictionary];
        }
    }
    return _systemDict;
}

+ (NSString *)systemPath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[System_Info_Path stringByAppendingPathExtension:@"plist"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    return path;
}

@end
