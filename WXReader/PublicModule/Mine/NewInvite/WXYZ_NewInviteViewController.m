//
//  WXYZ_NewInviteViewController.m
//  WXReader
//
//  Created by geng on 2020/10/2.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_NewInviteViewController.h"
#import "WXYZ_InviteTopTableViewCell.h"
#import "WXYZ_InviteBottomTableViewCell.h"
#import "WXYZ_ShareModel.h"
#import "WXYZ_TextfieldAlertView.h"
@interface WXYZ_NewInviteViewController () <UITableViewDelegate,UITableViewDataSource,WXYZ_InviteTopTableViewCellDelegate>

@property (nonatomic, strong) WXYZ_ShareModel *shareInfo;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation WXYZ_NewInviteViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialize];
    [self createSubViews];
}


- (void)initialize
{
    [self setNavigationBarTitle:@"邀请好友"];
    
}

- (void)createSubViews {
    self.view.backgroundColor = WX_COLOR_WITH_HEX(0x4846CE);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"invite"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(300);
    }];
    
     self.mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
     self.mainTableView.frame = CGRectMake(0, PUB_NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT);
     self.mainTableView.backgroundColor = [UIColor clearColor];
     self.mainTableView.showsVerticalScrollIndicator = NO;
     self.mainTableView.showsHorizontalScrollIndicator = NO;
     self.mainTableView.estimatedRowHeight = 100;
     self.mainTableView.rowHeight = UITableViewAutomaticDimension;
     self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     self.mainTableView.delegate = self;
     self.mainTableView.dataSource = self;
     if (@available(iOS 11.0, *)) {
         self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
     } else {
         // Fallback on earlier versions
     }
    
    [self.mainTableView registerClass:[WXYZ_InviteTopTableViewCell class] forCellReuseIdentifier:@"WXYZ_InviteTopTableViewCell"];
    [self.mainTableView registerClass:[WXYZ_InviteBottomTableViewCell class] forCellReuseIdentifier:@"WXYZ_InviteBottomTableViewCell"];
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 270)];
    headView.backgroundColor = [UIColor clearColor];
    self.mainTableView.tableHeaderView = headView;
    
    [self.view addSubview:self.mainTableView];
    
    [self fetchData];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.shareInfo != nil) {
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WXYZ_InviteTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_InviteTopTableViewCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell showInfo:self.shareInfo];
        return cell;
    } else {
        WXYZ_InviteBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_InviteBottomTableViewCell" forIndexPath:indexPath];
        [cell showData:self.dataArray[indexPath.row]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 350;
    } else {
        return 80;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        headView.backgroundColor = [UIColor clearColor];
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-24, 10)];
        spaceView.backgroundColor = [UIColor whiteColor];
        [headView addSubview:spaceView];
        [self setCornerOnTop:CGSizeMake(4, 4) withView:spaceView];
        return headView;
    }
    return nil;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        footerView.backgroundColor = [UIColor clearColor];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-24, 10)];
        spaceView.backgroundColor = [UIColor whiteColor];
        [footerView addSubview:spaceView];
        
        [self setCornerOnBottom:CGSizeMake(4, 4) withView:spaceView];
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 30;
}

- (void)fetchData {
      WS(weakSelf)
      [WXYZ_NetworkRequestManger POST:App_Share parameters:nil model:WXYZ_ShareModel.class success:^(BOOL isSuccess, WXYZ_ShareModel *_Nullable t_model, WXYZ_NetworkRequestModel *requestModel) {
          if (isSuccess) {
              weakSelf.shareInfo = t_model;
              if (weakSelf.shareInfo != nil && weakSelf.shareInfo.inviteInfo != nil) {
                  NSArray *array = weakSelf.shareInfo.inviteInfo[@"userList"];
                  if (array != nil && array.count > 0) {
                      [self.dataArray addObjectsFromArray:array];
                  } else {
                      NSDictionary *dic1 = @{@"code":@"-1"};
                      [self.dataArray addObject:dic1];
                  }
              }
              [weakSelf.mainTableView reloadData];
          }
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"网络异常"];
      }];
}

#pragma mark - WXYZ_InviteTopTableViewCellDelegate
- (void)onBindUser {
    WS(weakSelf);
    WXYZ_TextfieldAlertView *alert = [[WXYZ_TextfieldAlertView alloc] init];
    alert.isInvite = true;
    alert.alertViewTitle = @"输入邀请人邀请码";
    alert.placeHoldTitle =  @"";
    alert.endEditedBlock = ^(NSString *inputText) {
        [weakSelf bindUser:inputText];
    };
    [alert showAlertView];
}

- (void)bindUser:(NSString *)user {
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POST:@"/invite/bind-code" parameters:@{@"invite_code":user} model:nil success:^(BOOL isSuccess, NSDictionary *_Nullable data, WXYZ_NetworkRequestModel *requestModel) {
        if ([data[@"code"] intValue] == 0) {
            NSDictionary *tData = data[@"data"];
            if (tData[@"bind_user"] != nil) {
                weakSelf.shareInfo.bind_user = tData[@"bind_user"];
            }
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeSuccess alertTitle:@"绑定成功"];
            [weakSelf.mainTableView reloadData];
        } else {
            if (data[@"msg"] != nil) {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:data[@"msg"]];
            } else {
                [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"网络异常"];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:@"网络异常"];
    }];
}

- (void)onShare {
    [self systemShareWithTitle:self.shareInfo.title shareUrl:[NSURL URLWithString:self.shareInfo.link]];
}

// 系统分享
- (void)systemShareWithTitle:(NSString *)title shareUrl:(NSURL *)shareUrl {
    NSString *shareText = title ?: @"";
    UIImage *shareImage = [UIImage imageNamed:[[[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject]];
    NSArray *activityItems = @[shareText, shareImage, shareUrl ?: [NSURL URLWithString:@""]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.modalInPopover = YES;
    activityVC.excludedActivityTypes = @[
    UIActivityTypePostToFacebook,
    UIActivityTypePostToTwitter,
    UIActivityTypePostToWeibo,
    UIActivityTypeMessage,
    UIActivityTypeMail,
    UIActivityTypePrint,
    UIActivityTypeCopyToPasteboard,
    UIActivityTypeAssignToContact,
    UIActivityTypeSaveToCameraRoll,
    UIActivityTypeAddToReadingList,
    UIActivityTypePostToFlickr,
    UIActivityTypePostToVimeo,
    UIActivityTypePostToTencentWeibo,
    UIActivityTypeAirDrop,
    UIActivityTypeOpenInIBooks
    ];
    UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
    };
    activityVC.completionWithItemsHandler = itemsBlock;
    [[WXYZ_ViewHelper getCurrentViewController] presentViewController:activityVC animated:YES completion:nil];
}


- (void)setCornerOnTop:(CGSize)size withView:(UIView *)view {
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                     byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                           cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;

}
- (void)setCornerOnBottom:(CGSize)size withView:(UIView *)view  {
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                     byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                           cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
