//
//  WXYZ_UserDataViewController.m
//  WXReader
//
//  Created by Andrew on 2018/7/17.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_UserDataViewController.h"
#import "WXYZ_BindPhoneViewController.h"
#import "WXYZ_CancelAccountViewController.h"

#import "WXYZ_UserDataTableViewCell.h"

#import "WXYZ_WechatManager.h"
#import "WXYZ_QQManager.h"
#import "WXYZ_URLProtocol.h"

#import "WXYZ_ImagePicker.h"
#import "WXYZ_TextfieldAlertView.h"

#import "WXYZ_UserDataModel.h"

typedef NS_ENUM(NSUInteger, WXYZ_UserInfoStyle) {
    WXYZ_UserInfoStyleName,
    WXYZ_UserInfoStyleGender,
    WXYZ_UserInfoStyleAvatar
};

@interface WXYZ_UserDataViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, DPImagePickerDelegate, WXYZ_WeChatManagerDelegate, WXYZ_QQManagerDelegate>

@property (nonatomic, strong) WXYZ_UserDataModel *userDataModel;

@end

@implementation WXYZ_UserDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self netRequest];
    [self setStatusBarDefaultStyle];
}

- (void)initialize
{
    [WXYZ_URLProtocol startMonitor];
    [self setNavigationBarTitle:@"个人资料"];
    
#if WX_WeChat_Login_Mode
    [WXYZ_WechatManager sharedManager].delegate = self;
#endif
#if WX_QQ_Login_Mode
    [WXYZ_QQManager sharedManager].delegate = self;
#endif
}

- (void)createSubviews
{
    self.mainTableViewGroup.delegate = self;
    self.mainTableViewGroup.dataSource = self;
    [self.view addSubview:self.mainTableViewGroup];
    
    [self.mainTableViewGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.userDataModel.panel_list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userDataModel.panel_list[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_UserDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_UserDataTableViewCell"];
    
    if (!cell) {
        cell = [[WXYZ_UserDataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_UserDataTableViewCell"];
    }
    
    cell.cellModel = self.userDataModel.panel_list[indexPath.section][indexPath.row];
    cell.hiddenEndLine = (indexPath.row == self.userDataModel.panel_list[indexPath.section].count - 1);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf)
    WXYZ_UserDataTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // 修改头像
    if ([cell.cellModel.action isEqualToString:@"avatar"] && cell.cellModel.is_click) {
        WXYZ_ImagePicker *picker = [WXYZ_ImagePicker sharedManager];
        picker.editPhoto = YES;
        picker.delegate = self;
        [picker showInController:self];
    }
    
    // 修改昵称
    if ([cell.cellModel.action isEqualToString:@"nickname"] && cell.cellModel.is_click) {
        WXYZ_TextfieldAlertView *alert = [[WXYZ_TextfieldAlertView alloc] init];
        alert.alertViewTitle = @"修改昵称";
        alert.placeHoldTitle = cell.cellModel.desc ?: @"";
        alert.endEditedBlock = ^(NSString *inputText) {
            [weakSelf setUserInfoNetRequestWithStyle:WXYZ_UserInfoStyleName url:Set_NickName parametersKey:@"nickname" parametersValue:inputText editedImage:nil];
        };
        [alert showAlertView];
    }
    
    if ([cell.cellModel.action isEqualToString:@"gender"] && cell.cellModel.is_click) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if (is_iPad) {
            UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
            
            if (popover) {
                popover.sourceView = self.view;
                popover.sourceRect = self.view.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
            }
        }
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf setUserInfoNetRequestWithStyle:WXYZ_UserInfoStyleGender url:Set_Gender parametersKey:@"gender" parametersValue:@"2" editedImage:nil];
        }]];

        [actionSheet addAction:[UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf setUserInfoNetRequestWithStyle:WXYZ_UserInfoStyleGender url:Set_Gender parametersKey:@"gender" parametersValue:@"1" editedImage:nil];
        }]];

        [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

        [[WXYZ_ViewHelper getWindowRootController] presentViewController:actionSheet animated:YES completion:nil];
    }
    
    // 注销账号
    if ([cell.cellModel.action isEqualToString:@"cancel"] && cell.cellModel.is_click) {
        [self.navigationController pushViewController:[[WXYZ_CancelAccountViewController alloc] init] animated:YES];
    }
    
    // 绑定手机号
    if ([cell.cellModel.action isEqualToString:@"mobile"] && cell.cellModel.is_click) {
        [self.navigationController pushViewController:[[WXYZ_BindPhoneViewController alloc] init] animated:YES];
    }
    
    // 绑定微信
    if ([cell.cellModel.action isEqualToString:@"wechat"] && cell.cellModel.is_click) {
        [self weChatBindingRequest];
    }
    
    // 绑定QQ
    if ([cell.cellModel.action isEqualToString:@"qq"] && cell.cellModel.is_click) {
        [self qqBindingRequest];
    }
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHalfMargin;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = kGrayViewColor;
    return view;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = kGrayViewColor;
    return view;
}

#pragma mark - DPImagePickerDelegate
- (void)imagePickerDidFinishPickingWithOriginalImage:(UIImage *)originalImage editedImage:(UIImage *)editedImage;
{
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeLoading alertTitle:@"上传中"];
    
    [self setUserInfoNetRequestWithStyle:WXYZ_UserInfoStyleAvatar url:Set_Avatar parametersKey:@"avatar" parametersValue:[WXYZ_ViewHelper getBase64StringWithImageData:UIImagePNGRepresentation(editedImage)] editedImage:[WXYZ_ViewHelper fixOrientation:editedImage]];
}

- (void)setUserInfoNetRequestWithStyle:(WXYZ_UserInfoStyle)style url:(NSString *)url parametersKey:(NSString *)parametersKey parametersValue:(NSString *)parametersValue editedImage:(UIImage *)editedImage
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:url parameters:@{parametersKey:parametersValue} model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            switch (style) {
                case WXYZ_UserInfoStyleName:
                {
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"修改成功"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_NickName_Changed object:parametersValue];
                }
                    break;
                case WXYZ_UserInfoStyleGender:
                {
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"修改成功"];
                }
                    break;
                case WXYZ_UserInfoStyleAvatar:
                {
                    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"修改成功"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Avatar_Changed object:editedImage];
                }
                    break;
                default:
                    break;
            }
            
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg];
        }
        
        [weakSelf netRequest];
    } failure:nil];
}

- (void)weChatBindingRequest
{
    if (![WXYZ_WechatManager isInstallWechat]) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"您的手机没有安装微信"];
        return ;
    }
    [[WXYZ_WechatManager sharedManager] tunedUpWechatWithState:WXYZ_WechatStateBinding];
}

- (void)wechatResponseSuccess:(WXYZ_UserInfoManager *)userData
{
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"微信绑定成功"];
    [self netRequest];
}

- (void)wechatResponseFail:(NSString *)error
{
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"绑定失败"];
}

- (void)qqBindingRequest {
    if (![WXYZ_QQManager isInstallQQ]) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"您的手机没有安装QQ或TIM"];
        return ;
    }
    [[WXYZ_QQManager sharedManager] tunedUpQQWithState:WXYZ_QQStateBinding];
}

- (void)qqResponseSuccess:(WXYZ_MineUserModel *)userData {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"QQ绑定成功"];
    [self netRequest];
}

- (void)qqResponseFail:(NSString *)error {
    [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"绑定失败"];
}

- (void)netRequest
{
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:User_Data parameters:nil model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            WXYZ_UserDataModel *model = [WXYZ_UserDataModel modelWithDictionary:t_model[@"data"]];
            weakSelf.userDataModel = model;
            
        }
        [weakSelf.mainTableViewGroup reloadData];
    } failure:nil];
}

- (void)dealloc {
    [WXYZ_URLProtocol stopMonitor];
}

@end
