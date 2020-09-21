//
//  WXYZ_AppraiseTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2020/4/13.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_AppraiseTableViewCell.h"

@implementation WXYZ_AppraiseTableViewCell
{
    UIImageView *avatarImage;   //头像
    UILabel *nickNameLabel;     //昵称
    UIImageView *vipImageView;  // VIP标识
    UILabel *timeLabel;         //发布时间
    YYLabel *replyCommentLabel; //二级评论
    UILabel *commentLabel;      //评论
    UILabel *commentBookName;
    UILabel *commentCountLabel;
}

- (void)createSubviews
{
    [super createSubviews];
    
    // 头像
    avatarImage = [[UIImageView alloc] initWithCornerRadiusAdvance:35.0f / 2 rectCornerType:UIRectCornerAllCorners];
    [self.contentView addSubview:avatarImage];
    
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(kMargin);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(kHalfMargin);
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
    [self addSubview:vipImageView];
    
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
        make.left.mas_equalTo(nickNameLabel.mas_left);
        make.bottom.mas_equalTo(avatarImage.mas_bottom);
        make.right.mas_equalTo(self.contentView.mas_right);
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
        make.left.mas_equalTo(nickNameLabel.mas_left);
        make.top.mas_equalTo(avatarImage.mas_bottom);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    
    // 评论
    commentLabel = [[UILabel alloc] init];
    commentLabel.textAlignment = NSTextAlignmentLeft;
    commentLabel.font = kMainFont;
    commentLabel.numberOfLines = 0;
    commentLabel.textColor = kBlackColor;
    [self.contentView addSubview:commentLabel];
    
    [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nickNameLabel.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.top.mas_equalTo(replyCommentLabel.mas_bottom).with.offset(kHalfMargin);
        make.height.mas_equalTo(200);
    }];
    
    commentCountLabel = [[UILabel alloc] init];
    commentCountLabel.font = kFont10;
    commentCountLabel.textAlignment = NSTextAlignmentRight;
    commentCountLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:commentCountLabel];
    
    [commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kHalfMargin);
        make.top.mas_equalTo(commentLabel.mas_bottom).with.offset(kHalfMargin);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(15);
    }];
    
    commentBookName = [[UILabel alloc] init];
    commentBookName.font = kFont10;
    commentBookName.textAlignment = NSTextAlignmentLeft;
    commentBookName.textColor = kGrayTextColor;
    [self.contentView addSubview:commentBookName];
    
    [commentBookName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nickNameLabel.mas_left);
        make.right.mas_equalTo(commentCountLabel.mas_left).with.offset(- kHalfMargin);
        make.centerY.mas_equalTo(commentCountLabel.mas_centerY);
        make.height.mas_equalTo(commentCountLabel.mas_height);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- kHalfMargin).priorityLow();
    }];
    
}

- (void)setCommentsDetailModel:(WXYZ_CommentsDetailModel *)commentsDetailModel
{
    if (!commentsDetailModel) {
        return;
    }
    
    _commentsDetailModel = commentsDetailModel;
    
    timeLabel.text = [NSString stringWithFormat:@"%@",commentsDetailModel.time?:@""];
    
    commentLabel.text = [NSString stringWithFormat:@"%@",commentsDetailModel.content?:@""];
    
    [commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabelFont:commentLabel.font labelWidth:(SCREEN_WIDTH - 35.0f - kMargin) labelText:commentLabel.text] - kHalfMargin);
    }];
    
    [avatarImage setImageWithURL:[NSURL URLWithString:commentsDetailModel.avatar?:@""] placeholder:HoldUserAvatar options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    
    nickNameLabel.text = [NSString stringWithFormat:@"%@",commentsDetailModel.nickname?:@""];
    [nickNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:nickNameLabel]);
    }];
    
    if (commentsDetailModel.is_vip == 1) {
        vipImageView.hidden = NO;
    } else {
        vipImageView.hidden = YES;
    }
    
    commentCountLabel.text = [NSString stringWithFormat:@"%@条回复", [WXYZ_UtilsHelper formatStringWithInteger:commentsDetailModel.reply_num]];
    [commentCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
       make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabel:commentCountLabel]);
    }];
    
    commentBookName.text = commentsDetailModel.name_title?:@"";
    
    if (commentsDetailModel.reply_info.length > 0) {
        
        CGFloat replyHeight = [WXYZ_ViewHelper getDynamicHeightWithLabelFont:kFont11 labelWidth:(SCREEN_WIDTH - 2 * kMargin - 35.0f - kHalfMargin) labelText:commentsDetailModel.reply_info?:@""];
        NSString *replyInfo = [NSString stringWithFormat:@"%@",commentsDetailModel.reply_info?:@""];
        
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
    
    [commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([WXYZ_ViewHelper getDynamicHeightWithLabelFont:commentLabel.font labelWidth:(SCREEN_WIDTH - 35.0f - kMargin) labelText:commentLabel.text] - kHalfMargin);
    }];
    
}

@end
