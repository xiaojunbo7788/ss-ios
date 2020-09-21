//
//  WXYZ_AnnouncementView.m
//  GKADRollingView
//
//  Created by Gao on 2017/2/16.
//  Copyright © 2017年 gao. All rights reserved.
//

#import "WXYZ_AnnouncementView.h"

@interface WXYZ_AnnouncementView () <UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSTimer *_timer;
    UICollectionView *_collectionView;
}

@property (nonatomic, assign) NSInteger visibleItems;

@end

@implementation WXYZ_AnnouncementView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(SCREEN_WIDTH - 2 * kMargin, kLabelHeight);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollEnabled = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_collectionView];
    [_collectionView registerClass:[WXYZ_AnnouncementViewCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_AnnouncementViewCollectionViewCell"];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
}

- (void)setModelArr:(NSArray<WXYZ_AnnouncementModel *> *)modelArr
{
    if (_modelArr != modelArr) {
        _modelArr = modelArr;
        [_collectionView reloadData];
        
        if (_timer == nil) {
            _timer = [NSTimer timerWithTimeInterval:_duration?:5 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            [runloop addTimer:_timer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)starTimer
{
    //开启定时器
    [_timer setFireDate:[NSDate distantPast]];
}

- (void)stopTimer
{
    //暂停定时器
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)nextPage
{
    @try {
        if (self.visibleItems == _modelArr.count) {
            self.visibleItems = 0;
            [self->_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.visibleItems inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        self.visibleItems++;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.visibleItems inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        });
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _modelArr.count + 1;
}

- (WXYZ_AnnouncementViewCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WXYZ_AnnouncementViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WXYZ_AnnouncementViewCollectionViewCell" forIndexPath:indexPath];
    cell.textColor = self.textColor;
    cell.isCenter = self.isCenter;
    if (indexPath.row == 0) {
        cell.announcementModel = _modelArr.lastObject;
    } else {
        if (indexPath.row - 1 >= 0 && indexPath.row - 1 < _modelArr.count) {
            cell.announcementModel = _modelArr[indexPath.row - 1];
        } else {
            cell.announcementModel = _modelArr.firstObject;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        self.clickAdBlock(_modelArr.lastObject.content, indexPath.row);
    } else {
        self.clickAdBlock(_modelArr[indexPath.row - 1].content, indexPath.row - 1);
    }
}

@end
