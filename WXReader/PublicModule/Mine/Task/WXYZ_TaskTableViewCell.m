//
//  WXYZ_TaskTableViewCell.m
//  WXReader
//
//  Created by Andrew on 2018/11/15.
//  Copyright © 2018 Andrew. All rights reserved.
//

#import "WXYZ_TaskTableViewCell.h"
#import "WXYZ_TaskModel.h"

@implementation WXYZ_TaskTableViewCell
{
    UILabel *taskLabel;
    UILabel *taskDescLabel;
    UILabel *taskAward;
    
    UIButton *taskStateButton;
}

- (void)createSubviews
{
    [super createSubviews];
    
    taskLabel = [[UILabel alloc] init];
    taskLabel.font = kMainFont;
    taskLabel.textAlignment = NSTextAlignmentLeft;
    taskLabel.textColor = kBlackColor;
    [self.contentView addSubview:taskLabel];
    
    [taskLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMargin);
        make.top.mas_equalTo(kHalfMargin);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(20);
    }];
    
    taskDescLabel = [[UILabel alloc] init];
    taskDescLabel.textColor = kGrayTextColor;
    taskDescLabel.textAlignment = NSTextAlignmentLeft;
    taskDescLabel.font = kFont11;
    [self.contentView addSubview:taskDescLabel];
    
    [taskDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(taskLabel.mas_left);
        make.top.mas_equalTo(taskLabel.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH / 2);
        make.height.mas_equalTo(taskLabel.mas_height);
    }];
    
    taskAward = [[UILabel alloc] init];
    taskAward.textColor = kColorRGBA(251, 100, 26, 1);
    taskAward.textAlignment = NSTextAlignmentLeft;
    taskAward.font = kFont10;
    [self.contentView addSubview:taskAward];
    
    [taskAward mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(taskLabel.mas_right);
        make.centerY.mas_equalTo(taskLabel.mas_centerY);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(taskLabel.mas_height);
    }];
    
    taskStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    taskStateButton.backgroundColor = kColorRGBA(251, 100, 26, 1);
    taskStateButton.layer.cornerRadius = 10;
    taskStateButton.clipsToBounds = YES;
    [taskStateButton setTitle:@"去完成" forState:UIControlStateNormal];
    [taskStateButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [taskStateButton.titleLabel setFont:kFont10];
    [taskStateButton addTarget:self action:@selector(taskClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:taskStateButton];
    
    [taskStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- kMargin);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(50);
    }];
}

- (void)setTaskModel:(WXYZ_TaskListModel *)taskModel
{
    _taskModel = taskModel;
    
    if (taskModel) {
        taskLabel.text = taskModel.task_label;
        [taskLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([WXYZ_ViewHelper getDynamicWidthWithLabelFont:kMainFont labelHeight:20 labelText:taskModel.task_label]);
        }];
        
        
        taskDescLabel.text = taskModel.task_desc;
        taskAward.text = taskModel.task_award;
        if (taskModel.task_state == 0) {
            [taskStateButton setTitle:@"去完成" forState:UIControlStateNormal];
            taskStateButton.backgroundColor = kColorRGBA(251, 100, 26, 1);
        } else {
            [taskStateButton setTitle:@"已完成" forState:UIControlStateNormal];
            taskStateButton.backgroundColor = kColorRGBA(213, 216, 217, 1);
        }
    } else {
        
    }
}

- (void)taskClick
{
    if (_taskModel.task_state == 1) {
        return;
    }
    
    if (!WXYZ_UserInfoManager.isLogin && ![_taskModel.task_action isEqualToString:@"recharge"] && ![_taskModel.task_action isEqualToString:@"vip"]) {
        [WXYZ_LoginViewController presentLoginView];
        return;
    }
    
    if (self.taskClickBlock) {
        self.taskClickBlock(_taskModel.task_action);
    }
}

@end
