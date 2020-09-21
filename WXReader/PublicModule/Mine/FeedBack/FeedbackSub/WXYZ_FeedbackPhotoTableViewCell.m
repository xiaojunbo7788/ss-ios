//
//  WXYZ_FeedbackPhotoTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackPhotoTableViewCell.h"
#import "WXYZ_FeedbackAddCollectionViewCell.h"
#import "WXYZ_FeedbackCollectionViewCell.h"
#import "WMPhotoBrowser.h"
#import "WXYZ_FeedbackPhotoManager.h"
#import "NSObject+Observer.h"

@interface WXYZ_FeedbackPhotoTableViewCell ()

@property (nonatomic, strong) NSMutableArray *photosSource;

@property (nonatomic, strong) UICollectionView *mainCollectionView;

@end

@implementation WXYZ_FeedbackPhotoTableViewCell

- (void)createSubviews
{
    [super createSubviews];
    
    self.photosSource = [NSMutableArray array];
    
    UICollectionViewFlowLayout *mainCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    mainCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    mainCollectionViewFlowLayout.minimumLineSpacing = kHalfMargin;
    mainCollectionViewFlowLayout.minimumInteritemSpacing = 0;
    CGFloat width = (SCREEN_WIDTH - (2 * kHalfMargin) - (2 * mainCollectionViewFlowLayout.minimumLineSpacing)) / 3.0;
    mainCollectionViewFlowLayout.itemSize = CGSizeMake(width, width);
    
    self.mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:mainCollectionViewFlowLayout];
    self.mainCollectionView.userInteractionEnabled = YES;
    self.mainCollectionView.backgroundColor = [UIColor clearColor];
    self.mainCollectionView.showsVerticalScrollIndicator = NO;
    self.mainCollectionView.showsHorizontalScrollIndicator = NO;
    self.mainCollectionView.alwaysBounceVertical = YES;
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    if (@available(iOS 11.0, *)) {
        self.mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.mainCollectionView registerClass:[WXYZ_FeedbackCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_FeedbackCollectionViewCell"];
    [self.mainCollectionView registerClass:[WXYZ_FeedbackAddCollectionViewCell class] forCellWithReuseIdentifier:@"WXYZ_FeedbackAddCollectionViewCell"];
    [self.contentView addSubview:self.mainCollectionView];
    
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kHalfMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
        make.height.mas_equalTo(width);
        make.width.mas_equalTo(SCREEN_WIDTH - kMargin);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
    
    WS(weakSelf)
    [WXYZ_FeedbackPhotoManager sharedManager].deletePhotoBlock = ^(WXYZ_FeedbackPhotoModel * _Nonnull photoModel) {
        [weakSelf.photosSource removeObject:photoModel];
        [weakSelf.mainCollectionView reloadData];
        if (weakSelf.operationPhotosBlock) {
            weakSelf.operationPhotosBlock(weakSelf.photosSource);
        }
    };
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.photosSource.count < 3) {
        return self.photosSource.count + 1;
    }
    
    if (self.photosSource.count >= 3) {
        return 3;
    }
    
    return self.photosSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.photosSource.count && self.photosSource.count < 3) {
        static NSString *CellIdentifier = @"WXYZ_FeedbackAddCollectionViewCell";
        WXYZ_FeedbackAddCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        WS(weakSelf)
        static NSString *CellIdentifier = @"WXYZ_FeedbackCollectionViewCell";
        WXYZ_FeedbackCollectionViewCell __weak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.photoModel = [self.photosSource objectOrNilAtIndex:indexPath.row];
        cell.cellIndex = indexPath.row;
        cell.deleteImageBlock = ^(NSInteger index) {
            [weakSelf.mainCollectionView reloadData];
        };
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[collectionView cellForItemAtIndexPath:indexPath] isKindOfClass:[WXYZ_FeedbackAddCollectionViewCell class]]) {
        WXYZ_ImagePicker *picker = [WXYZ_ImagePicker sharedManager];
        picker.editPhoto = NO;
        picker.delegate = self;
        [picker showLibraryInController:[WXYZ_ViewHelper getCurrentViewController]];
    } else {
        WXYZ_FeedbackPhotoModel *photoModel = [self.photosSource objectOrNilAtIndex:indexPath.row];
        WMPhotoBrowser *browser = [WMPhotoBrowser new];
        browser.dataSource = @[photoModel.show_img].mutableCopy;
        browser.downLoadNeeded = YES;
        browser.currentPhotoIndex = 0;
        [[WXYZ_ViewHelper getCurrentViewController] presentViewController:browser animated:YES completion:nil];
    }
}

- (void)imagePickerDidFinishPickingWithOriginalImage:(UIImage *)originalImage editedImage:(UIImage *)editedImage
{
    WS(weakSelf)
    WXYZ_FeedbackPhotoModel *photoModel = [[WXYZ_FeedbackPhotoModel alloc] init];
    photoModel.show_img = @"";
    [self.photosSource addObject:photoModel];
    [self.mainCollectionView reloadData];
    
    [[WXYZ_FeedbackPhotoManager sharedManager] addPhotoImage:originalImage complete:^(WXYZ_FeedbackPhotoModel * _Nonnull photoModel) {
        if (photoModel) {
            [weakSelf.photosSource removeLastObject];
            [weakSelf.photosSource addObject:photoModel];
            [weakSelf.mainCollectionView reloadData];
            if (weakSelf.operationPhotosBlock) {
                weakSelf.operationPhotosBlock(weakSelf.photosSource);
            }            
        }
    }];
}

@end
