//
//  WXYZ_SearchHeaderView.m
//  WXReader
//
//  Created by Andrew on 2018/7/5.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_SearchHeaderView.h"
#import "WXYZ_SearchCollectionViewCell.h"
@interface WXYZ_SearchHeaderView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *mainCollectionView;
@property (nonatomic, strong) NSMutableArray *tagArray;
@property (strong, nonatomic) UILabel *headTag;
@end

@implementation WXYZ_SearchHeaderView
{
    CGRect headerViewFrame;
}


- (instancetype)init
{
    if (self = [super init]) {
        self.tagArray = [[NSMutableArray alloc] init];
        
        UILabel *headTag = [[UILabel alloc] init];
           headTag.textColor = kGrayTextColor;
           headTag.backgroundColor = [UIColor clearColor];
           headTag.text = @"热门标签";
           headTag.font = kFont12;
           [self addSubview:headTag];
        self.headTag = headTag;
           [headTag mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.left.mas_equalTo(kMargin);
                  make.top.mas_equalTo(kHalfMargin + 5);
                  make.width.mas_equalTo(SCREEN_WIDTH / 2);
                  make.height.mas_equalTo(20);
           }];
           
           UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
           flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 2.0 * kMargin - 4 * kHalfMargin) / 5.0-1, 30);
           flowLayout.minimumInteritemSpacing = kHalfMargin;
           flowLayout.minimumLineSpacing = kHalfMargin;
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
           flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
           UICollectionView *mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
           self.mainCollectionView = mainCollectionView;
           mainCollectionView.showsHorizontalScrollIndicator = NO;
           mainCollectionView.showsVerticalScrollIndicator = NO;
           mainCollectionView.backgroundColor = [UIColor clearColor];
           mainCollectionView.pagingEnabled = YES;
           mainCollectionView.dataSource = self;
           mainCollectionView.delegate = self;
           mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
           [mainCollectionView registerClass:WXYZ_SearchCollectionViewCell.class forCellWithReuseIdentifier:@"WXYZ_SearchCollectionViewCell"];
           [self addSubview:mainCollectionView];
           [mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.left.equalTo(self).offset(kMargin);
               make.right.equalTo(self).offset(-kMargin);
               make.top.equalTo(headTag.mas_bottom).offset(10);
               make.height.mas_equalTo(80);
           }];
           
           
    }
    return self;
}

- (void)setHotWordArray:(NSArray *)hotWordArray
{
   
    _hotWordArray = hotWordArray;
    UILabel *headTitle = [[UILabel alloc] init];
    headTitle.textColor = kGrayTextColor;
    headTitle.backgroundColor = [UIColor clearColor];
    headTitle.text = @"热门搜索";
    headTitle.font = kFont12;
    [self addSubview:headTitle];
    
    [headTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(self.mainCollectionView.mas_bottom).offset(10);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(20);
    }];
    
    int buttonNum = 2;//每行多少按钮
    CGFloat button_W = SCREEN_WIDTH / 2;//按钮宽
    CGFloat margin_Y = 2 * kMargin*2+80;//第一个按钮的Y坐标
    CGFloat button_H = 35;//按钮高
    CGFloat button_Y = 0;
    for (int i = 0; i < hotWordArray.count; i++) {
        int row = i / buttonNum;//行号
        int loc = i % buttonNum;//列号
        CGFloat button_X = button_W * loc;
        button_Y = margin_Y + button_H * row;
        
        UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bottomButton.frame = CGRectMake(button_X, button_Y, button_W, button_H);
        bottomButton.backgroundColor = [UIColor clearColor];
        bottomButton.tag = i;
        [bottomButton addTarget:self action:@selector(hotWorkClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bottomButton];
        
        UILabel *indexLabel = [[UILabel alloc] init];
        indexLabel.backgroundColor = kColorRGBA(203, 204, 204, 1);
        indexLabel.text = [NSString stringWithFormat:@"%d", i + 1];
        indexLabel.font = kFont8;
        indexLabel.layer.cornerRadius = 2;
        indexLabel.clipsToBounds = YES;
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.textAlignment = NSTextAlignmentCenter;
        [bottomButton addSubview:indexLabel];
        
        switch (i) {
            case 0:
                indexLabel.backgroundColor = kColorRGBA(227, 58, 52, 1);
                break;
            case 1:
                indexLabel.backgroundColor = kColorRGBA(238, 132, 55, 1);
                break;
            case 2:
                indexLabel.backgroundColor = kColorRGBA(237, 173, 72, 1);
                break;
                
            default:
                break;
        }
        
        [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kMargin);
            make.centerY.mas_equalTo(bottomButton.mas_centerY);
            make.height.width.mas_equalTo(13);
        }];
        
        UILabel *hotWordLabel = [[UILabel alloc] init];
        hotWordLabel.textAlignment = NSTextAlignmentLeft;
        hotWordLabel.textColor = kBlackColor;
        hotWordLabel.font = kMainFont;
        hotWordLabel.text = [hotWordArray objectOrNilAtIndex:i];
        [bottomButton addSubview:hotWordLabel];
        
        [hotWordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(indexLabel.mas_right).with.offset(8);
            make.centerY.mas_equalTo(indexLabel.mas_centerY);
            make.right.mas_equalTo(bottomButton.mas_right);
            make.height.mas_equalTo(bottomButton.mas_height);
        }];
    }
    
    headerViewFrame = CGRectMake(0, 0, SCREEN_WIDTH, button_Y + button_H + kMargin);
    self.frame = headerViewFrame;
}

- (void)hotWorkClick:(UIButton *)sender
{
    NSString *hotWord = [_hotWordArray objectOrNilAtIndex:sender.tag];
    if (self.hotWorkClickBlock) {
        self.hotWorkClickBlock(hotWord);
    }
}

- (void)showTagArray:(NSArray *)tagArray {
    if (tagArray != nil) {
        [_tagArray addObjectsFromArray:tagArray];
          [_tagArray insertObject:@{@"id":@"-1",@"title":@"更多"} atIndex:tagArray.count];
          [self.mainCollectionView reloadData];
    }
  
}

- (void)setSmallFrame
{
    self.frame = CGRectMake(0, 0, 0, 0);
}

- (void)setNormalFrame
{
    self.frame = headerViewFrame;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tagArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_SearchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WXYZ_SearchCollectionViewCell" forIndexPath:indexPath];
    [cell showInfo:self.tagArray[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.tagArray[indexPath.item];
    if ([dic[@"id"] intValue] == -1) {
        [self.delegate selectMoreTag];
    } else {
        [self.delegate selectTagBy:dic];
    }
}

@end
