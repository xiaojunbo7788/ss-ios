//
//  WXYZ_ADBasicView.m
//  WXReader
//
//  Created by LL on 2020/7/27.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ADBasicView.h"

@implementation WXYZ_ADBasicView

- (instancetype)initWithFrame:(CGRect)frame adType:(WXYZ_ADViewType)type adPosition:(WXYZ_ADViewPosition)position {
    if (self = [super initWithFrame:frame]) {
        self.adType = type;
        self.adPosition = position;
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    self.backgroundColor = kGrayViewColor;
}

- (void)clickAd {
    [WXYZ_NetworkRequestManger POST:AdVert_Click parameters:@{@"advert_id":[WXYZ_UtilsHelper formatStringWithInteger:self.adModel.advert_id]} model:nil success:nil failure:nil];
}

- (void)requestADWithType:(WXYZ_ADViewType)type postion:(WXYZ_ADViewPosition)position complete:(void(^)(WXYZ_ADModel * _Nullable adModel, NSString *msg))complete {
    NSDictionary *params = @{
           @"type" : @(type),
           @"position" : @(position)
       };
       
    [WXYZ_NetworkRequestManger POST:Advert_Info parameters:params model:WXYZ_ADModel.class success:^(BOOL isSuccess, WXYZ_ADModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
        if (isSuccess) {
            !complete ?: complete(t_model, requestModel.msg ?: @"");
        } else {
            !complete ?: complete(nil, requestModel.msg ?: @"");
        }
    } failure:nil];
}

@end
