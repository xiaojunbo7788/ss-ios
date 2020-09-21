//
//  WXYZ_BookMarkModel.m
//  WXReader
//
//  Created by LL on 2020/5/23.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookMarkModel.h"

@implementation WXYZ_BookMarkModel

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:self.class]) return NO;
    return [self hash] == [object hash];
}

- (NSUInteger)hash {
    return [self modelHash];
}

@end
