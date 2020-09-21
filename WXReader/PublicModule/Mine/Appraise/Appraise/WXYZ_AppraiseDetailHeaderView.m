//
//  WXYZ_AppraiseDetailHeaderView.m
//  WXReader
//
//  Created by Andrew on 2020/4/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AppraiseDetailHeaderView.h"

@implementation WXYZ_AppraiseDetailHeaderView
{
    UIImageView *avatarImage;   //头像
    UILabel *nickNameLabel;     //昵称
    UIImageView *vipImageView;  // VIP标识
    UILabel *timeLabel;         //发布时间
    UILabel *commentLabel;      //评论
    YYLabel *replyCommentLabel; // 二级评论
    
    WXYZ_ProductionCoverView *bookImageView;
    
    UIButton *bookBottomView;
    UILabel *bookTitleLabel;
    UILabel *authorLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    // 头像
    avatarImage = [[UIImageView alloc] initWithCornerRadiusAdvance:35.0f / 2 rectCornerType:UIRectCornerAllCorners];
    [self.contentView addSubview:avatarImage];
    
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kMargin);
        make.width.height.mas_equalTo(35.0f);
    }];
    
    // 昵称
    nickNameLabel = [[UILabel alloc] init];
    nickNameLabel.textColor = kGrayTextDeepColor;
    nickNameLabel.font = kFont13;
    nickNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:nickNameLabel];
    
    [nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(avatarImage.mas_right).with.offset(kHalfMargin);
        make.top.mas_equalTo(avatarImage.mas_top);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(avatarImage.mas_height).multipliedBy(0.6);
    }];
    
    vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_vip_normal"]];
    vipImageView.hidden = YES;
    [self.contentView addSubview:vipImageView];
    
    [vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nickNameLabel.mas_right);
        make.centerY.mas_equalTo(nickNameLabel.mas_centerY);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(kGeometricWidth(10, 138, 48));
    }];
    
    timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.font = kFont10;
    timeLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:timeLabel];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(avatarImage.mas_right).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(avatarImage.mas_bottom);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(avatarImage.mas_height).multipliedBy(0.4);
    }];
    
    // 二级评论
    replyCommentLabel = [[YYLabel alloc] init];
    replyCommentLabel.textAlignment = NSTextAlignmentLeft;
    replyCommentLabel.textColor = kGrayTextDeepColor;
    replyCommentLabel.font = kFont13;
    replyCommentLabel.backgroundColor = kGrayViewColor;
    replyCommentLabel.numberOfLines = 0;
    replyCommentLabel.textContainerInset = UIEdgeInsetsMake(6, 5, 4, 5);
    [self.contentView addSubview:replyCommentLabel];
    
    [replyCommentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(avatarImage.mas_left);
        make.top.mas_equalTo(avatarImage.mas_bottom);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    
    // 评论
    commentLabel = [[UILabel alloc] init];
    commentLabel.textAlignment = NSTextAlignmentLeft;
    commentLabel.font = kFont12;
    commentLabel.numberOfLines = 0;
    commentLabel.textColor = KGrayTextMiddleColor;
    [self.contentView addSubview:commentLabel];
    
    [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(replyCommentLabel.mas_bottom).with.offset(kHalfMargin);
        make.height.mas_equalTo(200);
    }];
    
    bookBottomView = [UIButton buttonWithType:UIButtonTypeCustom];
    bookBottomView.backgroundColor = kGrayViewColor;
    [bookBottomView addTarget:self action:@selector(commentProductionClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:bookBottomView];
    
    [bookBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(commentLabel.mas_bottom).with.offset(kHalfMargin);
        make.height.mas_equalTo(kGeometricHeight(SCREEN_WIDTH, 3, 1) - kMargin);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
    bookImageView = [[WXYZ_ProductionCoverView alloc] initWithProductionType:WXYZ_ProductionTypeBook productionCoverDirection:WXYZ_ProductionCoverDirectionVertical];
    bookImageView.userInteractionEnabled = NO;
    [bookBottomView addSubview:bookImageView];
    
    [bookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookBottomView.mas_left).with.offset(kHalfMargin);
        make.centerY.mas_equalTo(bookBottomView.mas_centerY);
        make.height.mas_equalTo(bookBottomView.mas_height).with.offset(- kMargin);
        make.width.mas_equalTo(kGeometricWidth(kGeometricHeight(SCREEN_WIDTH, 3, 1) - 2 * kMargin, 3, 4));
    }];
    
    bookTitleLabel = [[UILabel alloc] init];
    bookTitleLabel.textColor = kBlackColor;
    bookTitleLabel.textAlignment = NSTextAlignmentLeft;
    bookTitleLabel.numberOfLines = 1;
    bookTitleLabel.font = kMainFont;
    [bookBottomView addSubview:bookTitleLabel];
    
    [bookTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookImageView.mas_right).with.offset(kHalfMargin);
        make.bottom.mas_equalTo(bookBottomView.mas_centerY);
        make.right.mas_equalTo(bookBottomView.mas_right).with.offset(- kHalfMargin);
        make.height.mas_equalTo(40);
    }];
    
    authorLabel = [[UILabel alloc] init];
    authorLabel.textColor = kGrayTextColor;
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.font = kFont10;
    [bookBottomView addSubview:authorLabel];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bookTitleLabel.mas_left);
        make.right.mas_equalTo(bookTitleLabel.mas_right);
        make.height.mas_equalTo(30);
        make.top.mas_equalTo(bookBottomView.mas_centerY);
    }];
}

- (void)setAppraiseDetailModel:(WXYZ_AppraiseDetailModel *)appraiseDetailModel
{
    _appraiseDetailModel = appraiseDetailModel;
    
    timeLabel.text = [NSString stringWithFormat:@"%@",appraiseDetailModel.time?:@""];
    
    commentLabel.text = [NSString stringWithFormat:@"%@",appraiseDetailModel.content?:@""];
    
    [commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabelFont:commentLabel.font labelWidth:(SCREEN_WIDTH - 35.0f - kMargin) labelText:commentLabel.text] - kHalfMargin);
    }];
    
    [avatarImage setImageWithURL:[NSURL URLWithString:appraiseDetailModel.avatar?:@""] placeholder:HoldUserAvatar options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    nickNameLabel.text = [NSString stringWithFormat:@"%@",appraiseDetailModel.nickname?:@""];
    [nickNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:nickNameLabel]);
    }];
    
    if (appraiseDetailModel.is_vip == 1) {
        vipImageView.hidden = NO;
    } else {
        vipImageView.hidden = YES;
    }
    
    bookImageView.coverImageURL = appraiseDetailModel.cover;
    
    bookTitleLabel.text = appraiseDetailModel.name?:@"";
    
    authorLabel.text = appraiseDetailModel.author?:@"";
    
    if (appraiseDetailModel.reply_info.length > 0) {
        CGFloat replyHeight = [WXYZ_ViewHelper getDynamicHeightWithLabelFont:kFont11 labelWidth:(SCREEN_WIDTH - 2 * kMargin - 35.0f - kHalfMargin) labelText:appraiseDetailModel.reply_info];
        NSString *replyInfo = [NSString stringWithFormat:@"%@",appraiseDetailModel.reply_info];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 3;
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:replyInfo];
        [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, replyInfo.length)];
        [attrString addAttribute:NSFontAttributeName value:kFont11 range:NSMakeRange(0, replyInfo.length)];
        
        replyCommentLabel.attributedText = attrString;
        [replyCommentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(avatarImage.mas_bottom).with.offset(kHalfMargin);
            make.height.mas_equalTo(replyHeight);
        }];
    } else {
        replyCommentLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
        [replyCommentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(avatarImage.mas_bottom);
            make.height.mas_equalTo(CGFLOAT_MIN);
        }];
    }
}

- (void)setProductionType:(WXYZ_ProductionType)productionType
{
    [super setProductionType:productionType];
    
    bookImageView.productionType = productionType;
}

- (void)commentProductionClick
{
    if (self.commentProductionClickBlock) {
        self.commentProductionClickBlock();
    }
}

@end
