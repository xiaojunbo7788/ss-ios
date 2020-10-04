//
//  DPTextfieldAlertView.h
//  WXDating
//
//  Created by Andrew on 2017/12/13.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXYZ_AlertView.h"

@interface WXYZ_TextfieldAlertView : WXYZ_AlertView

@property (nonatomic, assign) BOOL isInvite;
@property (nonatomic, copy) void(^endEditedBlock)(NSString *inputText);

@property (nonatomic, copy) NSString *placeHoldTitle;

@end
