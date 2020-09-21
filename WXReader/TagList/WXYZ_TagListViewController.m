//
//  WXYZ_TagListViewController.m
//  WXReader
//
//  Created by geng on 2020/9/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_TagListViewController.h"
#import "WXYZ_TagTableViewCell.h"
#import "WXYZ_TagBookViewController.h"

@interface WXYZ_TagListViewController () <UITableViewDataSource,UITableViewDelegate,WXYZ_TagTableViewCellDelegate>

@end

@implementation WXYZ_TagListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitle:@"标签列表"];
    // Do any additional setup after loading the view.
    [self createSubviews];
    [self netRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Hidden_Tabbar object:nil];
}

- (void)createSubviews {
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.height.mas_equalTo(SCREEN_HEIGHT - PUB_NAVBAR_HEIGHT - self.pageViewHeight);
        make.width.mas_equalTo(self.view.mas_width);
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    WXYZ_ProductionModel *productionModel = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WXYZ_TagTableViewCell"];
    if (!cell) {
        cell = [[WXYZ_TagTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WXYZ_TagTableViewCell"];
        cell.delegate  =self;
    }
    cell.detailArray = self.dataSourceArray;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WXYZ_ProductionModel *t_model = [self.dataSourceArray objectOrNilAtIndex:indexPath.row];
    WXYZ_ComicMallDetailViewController *vc = [[WXYZ_ComicMallDetailViewController alloc] init];
    vc.comic_id = t_model.production_id;
    [self.navigationController pushViewController:vc animated:YES];
}




- (void)netRequest {
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:MyTagList parameters:@{@"page_size":@"1000"} model:nil success:^(BOOL isSuccess, id _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            [self.dataSourceArray removeAllObjects];
            NSArray *list = t_model[@"data"][@"list"];
            [self.dataSourceArray addObjectsFromArray:list];
            [self.mainTableView reloadData];
           
        } else {
            [WXYZ_TopAlertManager showAlertWithType:WXYZ_TopAlertTypeError alertTitle:requestModel.msg ?: @""];
            if (requestModel.code == 302) {
                [WXYZ_UserInfoManager logout];
                [weakSelf netRequest];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
    }];
}

#pragma mark - WXYZ_TagTableViewCellDelegate
- (void)selectTag:(int)index {
    NSDictionary *dic = self.dataSourceArray[index];
    WXYZ_TagBookViewController *vc = [[WXYZ_TagBookViewController alloc] init];
    vc.classType = 1;
    vc.tagTitle = dic[@"title"];
    vc._id = dic[@"id"];
    [self.navigationController pushViewController:vc animated:true];
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
