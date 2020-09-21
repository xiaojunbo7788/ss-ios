//
//  WXYZ_FeedbackListModel.m
//  WXReader
//
//  Created by Andrew on 2019/12/28.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackListModel.h"

@implementation WXYZ_FeedbackListModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"list" : [WXYZ_FeedbackContentModel class]};
}

@end

@implementation WXYZ_FeedbackContentModel

@end
