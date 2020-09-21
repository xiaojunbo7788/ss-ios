//
//  WXYZ_CollectionController.m
//  WXReader
//
//  Created by geng on 2020/9/9.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_CollectionController.h"
#import "WXYZ_CollectionViewCell.h"
#import "WXYZ_CollectModel.h"
#import "WXZY_CollectionBookViewController.h"
@interface WXYZ_CollectionController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) LYEmptyView *emptyView2;
@property (nonatomic, copy) NSString *requestUrl;

@end

@implementation WXYZ_CollectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    switch (self.type) {
        case 1:
            self.requestUrl = MyLikeAuthor;
             [self setNavigationBarTitle:@"喜欢的作者"];
            break;
       case  2:
            self.requestUrl = MyLikeOriginal;
             [self setNavigationBarTitle:@"喜欢的原著"];
            break;
        case 3:
            self.requestUrl = MyLikeSinici;
            [self setNavigationBarTitle:@"喜欢的汉化组"];
            break;
        default:
            break;
    }
    
    self.emptyView2 = [LYEmptyView emptyActionViewWithImageStr:@"public_no_data" titleStr:@"暂无喜欢" detailStr:@"" btnTitleStr:@"" btnClickBlock:^{
           
       }];
        _emptyView2.hidden = true;
       _emptyView2.contentViewY = SCREEN_HEIGHT/2-200;
       _emptyView2.imageSize = CGSizeMake(200, 200);
       _emptyView2.autoShowEmptyView = NO;
       _emptyView2.titleLabFont = kMainFont;
       _emptyView2.titleLabTextColor = kGrayTextColor;
       _emptyView2.promptImageView.tintColor = kMainColor;
       _emptyView2.actionBtnBorderWidth = 1;
       _emptyView2.actionBtnBorderColor = kMainColor;
       _emptyView2.actionBtnTitleColor = kMainColor;
       _emptyView2.actionBtnHeight = 35;
       _emptyView2.actionBtnHorizontalMargin = 20;
    [self.view addSubview:self.emptyView2];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
             make.left.bottom.right.mas_equalTo(self.view);
    }];
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource =self;
    [self.mainCollectionView registerClass:[WXYZ_CollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_CollectionViewCell"];
    [self.view addSubview:self.mainCollectionView];
      
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(PUB_NAVBAR_HEIGHT);
        make.left.bottom.right.mas_equalTo(self.view);
    }];
    [self netRequest];
    // Do any additional setup after loading the view.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WXYZ_CollectionViewCell" forIndexPath:indexPath];
    [cell showInfo:self.dataSourceArray[indexPath.item]];
    return cell;
}


- (void)netRequest {
    
    WS(weakSelf)
    [WXYZ_NetworkRequestManger POSTQuick:self.requestUrl parameters:nil model:nil success:^(BOOL isSuccess, id _Nullable t_model, BOOL isCache, WXYZ_NetworkRequestModel *requestModel) {
        if (isSuccess) {
            NSArray *list = t_model[@"data"];
            for (NSDictionary *dic in list) {
                WXYZ_CollectModel *model = [WXYZ_CollectModel modelWithDictionary:dic];
                model.type = self.type;
                [self.dataSourceArray addObject:model];
            }
            if (self.dataSourceArray.count == 0) {
                self.mainCollectionView.hidden = true;
                self.emptyView2.hidden = false;
            }
             [self.mainCollectionView reloadData];
            
           
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 15, 10, 15);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 10*2 - 30)/3, 195);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WXYZ_CollectModel *model = self.dataSourceArray[indexPath.item];
    WXZY_CollectionBookViewController *vc = [[WXZY_CollectionBookViewController alloc] init];
    vc.listModel = model;
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
