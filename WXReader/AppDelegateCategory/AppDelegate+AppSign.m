//
//  AppDelegate+AppSign.m
//  WXReader
//
//  Created by Andrew on 2018/11/10.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "AppDelegate+AppSign.h"
#import "WXYZ_SignAlertView.h"
#import "WXYZ_SignModel.h"
#import "WXYZ_ProductionCollectionManager.h"

static NSArray *bookList;

@implementation AppDelegate (AppSign)

- (void)initUserSign
{
#if WX_Sign_Mode
    
    if (!WXYZ_UserInfoManager.isLogin) return;
    
    // 审核状态
    if (isMagicState) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [WXYZ_NetworkRequestManger POST:Sign_Click parameters:nil model:WXYZ_SignModel.class success:^(BOOL isSuccess, WXYZ_SignModel * _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            if (isSuccess) {
                if ((t_model.book.count > 0 || t_model.comic.count > 0) && t_model.award.length > 0 && t_model.tomorrow_award.length > 0) {
                    
                    NSMutableArray *t_arr = [NSMutableArray array];
                    
                    for (WXYZ_ProductionModel *t in t_model.book) {
                        t.productionType = WXYZ_ProductionTypeBook;
                        [t_arr addObject:t];
                    }
                    
                    for (WXYZ_ProductionModel *t in t_model.comic) {
                        t.productionType = WXYZ_ProductionTypeComic;
                        [t_arr addObject:t];
                    }
                    
                    for (WXYZ_ProductionModel *t in t_model.audio) {
                        t.productionType = WXYZ_ProductionTypeAudio;
                        [t_arr addObject:t];
                    }
                    
                    
                    WXYZ_SignAlertView *alert = [[WXYZ_SignAlertView alloc] init];
                    //    alert.awardTitle = t_model.award;
                    alert.alertViewTitle = t_model.award;
                    alert.alertViewDetailContent = t_model.tomorrow_award;
                    alert.alertViewContentLabel.font = kFont11;
                    alert.bookList = [t_arr copy];
                    [alert showAlertView];
                    
                    bookList = [t_arr copy];
                }
            }
        } failure:nil];
    });
#endif
    
}

@end
