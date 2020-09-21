//
//  WXYZ_FeedbackCenterModel.m
//  WXReader
//
//  Created by Andrew on 2019/12/25.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackCenterModel.h"

@implementation WXYZ_FeedbackCenterModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"help_list" : [WXYZ_HelpListModel class]};
}

@end

@implementation WXYZ_HelpListModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_QuestionListModel class]};
}

@end

@implementation WXYZ_QuestionListModel

@end
