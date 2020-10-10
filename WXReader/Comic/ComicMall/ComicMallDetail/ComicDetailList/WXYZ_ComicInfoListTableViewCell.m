//
//  WXYZ_ComicInfoListTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/8/17.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_ComicInfoListTableViewCell.h"

@interface WXYZ_ComicInfoListTableViewCell ()

@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSMutableArray<NSString *> *titleArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *collectArray;

@end

@implementation WXYZ_ComicInfoListTableViewCell
{
    UILabel *leftTitleLabel;
    UIView *backView;
}

- (NSMutableArray <NSString *>*)titleArray {
    if (!_titleArray) {
        _titleArray = [[NSMutableArray alloc] init];
    }
    return _titleArray;;
}

- (NSMutableArray <NSString *>*)collectArray {
    if (!_collectArray) {
        _collectArray = [[NSMutableArray alloc] init];
    }
    return _collectArray;
}


- (void)createSubviews
{
    [super createSubviews];
    
    leftTitleLabel = [[UILabel alloc] init];
    leftTitleLabel.textColor = kBlackColor;
    leftTitleLabel.textAlignment = NSTextAlignmentRight;
    leftTitleLabel.font = kMainFont;
    [self.contentView addSubview:leftTitleLabel];
    
    [leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(40);
    }];
    
    backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:backView];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.left.mas_equalTo(leftTitleLabel.mas_right).with.offset(kHalfMargin);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
    }];
}

- (void)setLeftTitleString:(NSString *)leftTitleString
{
    _leftTitleString = leftTitleString;
    
    leftTitleLabel.text = leftTitleString;
}

- (void)setDetailArray:(NSArray *)detailArray
{
    _detailArray = detailArray;
    
    CGFloat kScreenW = SCREEN_WIDTH - 70 - 3 * kHalfMargin;
    
    //间距
    CGFloat padding = 10;
    
    CGFloat titBtnX = 0;
    CGFloat titBtnH = 26;
    CGFloat titBtnY = (40 - titBtnH) / 2;
    
    for (int i = 0; i < detailArray.count; i++) {
        
         WXYZ_AuthorModel *authorModel;
         WXYZ_OriginalModel *originalModel;
         WXYZ_AuthorSiniciModel *authorSiniciModel;
        
        
        UILabel *titBtn = [[UILabel alloc] init];
        //设置按钮的样式
        titBtn.backgroundColor = [UIColor colorWithHexString:@"#F9F9F9"];
        titBtn.textColor = [UIColor colorWithHexString:@"#0A0A0A"];
        titBtn.font = kFont13;
        CGFloat titBtnW = 0.0;
        id objc = detailArray[i];
        if ([objc isKindOfClass:[NSString class]]) {
            titBtn.text = detailArray[i];
            //计算文字大小
            titBtnW = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont13 labelHeight:titBtnH labelText:detailArray[i]?:@""] + padding;
        } else if ([objc isKindOfClass:[WXYZ_AuthorModel class]]) {
            self.type = 1;
            authorModel = (WXYZ_AuthorModel*)objc;
            //作者
//            titBtn.text = authorModel.author;
            titBtn.text = authorModel.author;
            [self.titleArray addObject:authorModel.author];
            //计算文字大小
            titBtnW = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont13 labelHeight:titBtnH labelText:authorModel.author?:@""] + padding;
            
        } else if ([objc isKindOfClass:[WXYZ_OriginalModel class]]) {
            self.type = 2;
            //原著
            originalModel = (WXYZ_OriginalModel*)objc;
            titBtn.text = originalModel.original;
             [self.titleArray addObject:originalModel.original];
            //计算文字大小
            titBtnW = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont13 labelHeight:titBtnH labelText:originalModel.original?:@""] + padding;
        } else if ([objc isKindOfClass:[WXYZ_AuthorSiniciModel class]]) {
            self.type = 3;
            //汉化组
             authorSiniciModel = (WXYZ_AuthorSiniciModel*)objc;
            titBtn.text = authorSiniciModel.sinici;
             [self.titleArray addObject:authorSiniciModel.sinici];
            //计算文字大小
            titBtnW = [WXYZ_ViewHelper getDynamicWidthWithLabelFont:kFont13 labelHeight:titBtnH labelText:authorSiniciModel.sinici?:@""] + padding;
        }
        
       
        titBtn.layer.cornerRadius = titBtnH / 2;
        titBtn.clipsToBounds = YES;
        
       
        if (![objc isKindOfClass:[NSString class]]) {
            //判断按钮是否超过屏幕的宽
            if ((titBtnX + titBtnW+29) > kScreenW) {
                titBtnX = 0;
                titBtnY += titBtnH + padding;
            }
            NSString *title = titBtn.text;
            
             titBtn.textAlignment = NSTextAlignmentLeft;
            //设置按钮的位置
            titBtn.frame = CGRectMake(titBtnX, titBtnY, titBtnW+29, titBtnH);
            titBtn.text = [NSString stringWithFormat:@"   %@",titBtn.text];
            int x = titBtnX;
            titBtnX += titBtnW + padding + 29;
            WXYZ_CollectionModel *collectModel = (WXYZ_CollectionModel *)objc;
             [self.collectArray addObject:[NSString stringWithFormat:@"%i",collectModel.is_collect]];
            UIButton *collecBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            if (collectModel.is_collect == 1) {
                [collecBtn setImage:[UIImage imageNamed:@"s_like"] forState:UIControlStateNormal];
            } else {
                [collecBtn setImage:[UIImage imageNamed:@"us_like"] forState:UIControlStateNormal];
            }
            collecBtn.frame = CGRectMake(x+titBtnW+29-26, titBtnY, 26, 26);
            collecBtn.tag = i + 10;
            [collecBtn addTarget:self action:@selector(collect:) forControlEvents:UIControlEventTouchUpInside];
            [backView addSubview:titBtn];
            [self addButton:title frame:titBtn.frame];
            [backView addSubview:collecBtn];
        } else {
            //判断按钮是否超过屏幕的宽
            if ((titBtnX + titBtnW) > kScreenW) {
                titBtnX = 0;
                titBtnY += titBtnH + padding;
            }
            NSString *title = titBtn.text;
            titBtn.textAlignment = NSTextAlignmentCenter;
            //设置按钮的位置
            titBtn.frame = CGRectMake(titBtnX, titBtnY, titBtnW, titBtnH);
            titBtnX += titBtnW + padding;
            [backView addSubview:titBtn];
            [self addButton:title frame:titBtn.frame];
        }
    }
    
    [backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo((titBtnY + titBtnH + padding) < 40?40:(titBtnY + titBtnH + padding));
    }];
}

- (void)addButton:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title != nil) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = frame;
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    button.opaque = true;
    [backView addSubview:button];
}

- (void)collect:(UIButton *)collectBtn {
    if (!WXYZ_UserInfoManager.isLogin) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    NSString *collectUrl = Comic_Auctor_colloc;
    NSString *cancelCollectUrl = Comic_Del_Auctor_colloc;
    
   __block NSString *isCollect = self.collectArray[collectBtn.tag - 10];
    NSDictionary *parameters = @{@"author":self.titleArray[collectBtn.tag-10]};
    switch (self.type) {
        case 1:
            collectUrl = Comic_Auctor_colloc;
            cancelCollectUrl = Comic_Del_Auctor_colloc;
            
            parameters = @{@"author":self.titleArray[collectBtn.tag-10]};
            break;
        case 2:
            collectUrl = Comic_Original_colloc;
            cancelCollectUrl = Comic_Del_Original_colloc;
            parameters = @{@"original":self.titleArray[collectBtn.tag-10]};
            break;
        case 3:
            collectUrl = Comic_sinici_colloc;
            cancelCollectUrl = Comic_Del_sinici_colloc;
            parameters = @{@"sinici":self.titleArray[collectBtn.tag-10]};
            break;
        default:
            break;
    }
    
    if ([isCollect intValue] != 1) {
        [WXYZ_NetworkRequestManger POST:collectUrl parameters:parameters model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            isCollect = @"1";
            [self.collectArray replaceObjectAtIndex:collectBtn.tag - 10 withObject:isCollect];
                [collectBtn setImage:[UIImage imageNamed:@"s_like"] forState:UIControlStateNormal];
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
             
          }];
    } else {
        [WXYZ_NetworkRequestManger POST:cancelCollectUrl parameters:parameters model:nil success:^(BOOL isSuccess, id  _Nullable t_model, WXYZ_NetworkRequestModel * _Nonnull requestModel) {
            isCollect = @"0";
             [self.collectArray replaceObjectAtIndex:collectBtn.tag - 10 withObject:isCollect];
            [collectBtn setImage:[UIImage imageNamed:@"us_like"] forState:UIControlStateNormal];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [WXYZ_TopAlertManager showAlertWithError:error defaultText:nil];
              
        }];
    }
    
  
}

- (void)buttonPress:(UIButton *)button {
     //0 作者、1、标签、2、分类、3、汉化组、4、原著
    int classType = 0;
    if ([self.leftTitleString isEqualToString:@"标签"]) {
        classType = 1;
    } else if ([self.leftTitleString isEqualToString:@"分类"]) {
         classType = 2;
    } else if ([self.leftTitleString isEqualToString:@"作者"]) {
         classType = 0;
    } else if ([self.leftTitleString isEqualToString:@"原著"]) {
         classType = 4;
    } else if ([self.leftTitleString isEqualToString:@"汉化组"]) {
         classType = 3;
    }
    if (button.titleLabel.text != nil) {
        [self.delegate gotoTagList:classType withTitle:button.titleLabel.text];
    } else {
        [self.delegate gotoTagList:classType withTitle:@""];
    }
}

@end
