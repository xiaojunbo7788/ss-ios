//
//  WXYZ_FeedbackCollectionViewCell.m
//  WXReader
//
//  Created by Andrew on 2019/12/27.
//  Copyright © 2019 Andrew. All rights reserved.
//

#import "WXYZ_FeedbackCollectionViewCell.h"
#import "WXYZ_FeedbackPhotoManager.h"

@interface WXYZ_FeedbackCollectionViewCell ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UIButton *closeButton;
 
@end

@implementation WXYZ_FeedbackCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    self.feedbackImage = [[UIImageView alloc] init];
    self.feedbackImage.contentMode = UIViewContentModeScaleAspectFill;
    self.feedbackImage.clipsToBounds = YES;
    self.feedbackImage.image = HoldImage;
    [self addSubview:self.feedbackImage];
    
    [self.feedbackImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    self.activityView = [[UIActivityIndicatorView alloc] init];
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityView.hidesWhenStopped = YES;
    [self addSubview:self.activityView];
    
    [self.activityView startAnimating];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(30);
    }];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.hidden = YES;
    self.closeButton.adjustsImageWhenHighlighted = NO;
    [self.closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 10, 0)];
    [self.closeButton setImage:[UIImage imageNamed:@"feedback_photo_delete"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.width.height.mas_equalTo(self.mas_width).multipliedBy(0.3);
    }];
    
    
}

- (void)setPhotoModel:(WXYZ_FeedbackPhotoModel *)photoModel
{
    _photoModel = photoModel;
    
    if (photoModel.show_img.length > 0) {
        WS(weakSelf)
        [self.feedbackImage setImageWithURL:[NSURL URLWithString:photoModel.show_img] placeholder:HoldImage options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            [weakSelf.activityView stopAnimating];
            weakSelf.closeButton.hidden = NO;
        }];
    } else {
        self.feedbackImage.image = HoldImage;
        [self.activityView startAnimating];
        self.closeButton.hidden = YES;
    }
}

- (void)deleteClick
{
    [[WXYZ_FeedbackPhotoManager sharedManager] deletePhotoWithPhotoModel:self.photoModel];
}

@end
