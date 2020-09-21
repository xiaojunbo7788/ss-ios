//
//  WXYZ_BookMarkViewController.m
//  WXReader
//
//  Created by LL on 2020/5/23.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_BookMarkViewController.h"

#import "WXYZ_BookMarkModel.h"
#import "NSObject+Observer.h"
#import "WXYZ_ProductionReadRecordManager.h"
#import "WXYZ_ReaderBookManager.h"
#import "WXYZ_ReaderSettingHelper.h"
#import "NSString+WXYZ_NSString.h"
#import "TYTextContainer.h"
#import "NSAttributedString+TReaderPage.h"

#import "WXYZ_BookReaderViewController.h"
#import "WXYZ_BookMarkCell.h"

@interface WXYZ_BookMarkViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation WXYZ_BookMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableArray<WXYZ_BookMarkModel *> *t_arr = [[WXYZ_ProductionReadRecordManager bookMark:[WXYZ_UtilsHelper formatStringWithInteger:self.bookModel.production_id]] mutableCopy];
        
    t_arr = [[t_arr sortedArrayUsingComparator:^NSComparisonResult(WXYZ_BookMarkModel * _Nonnull obj1, WXYZ_BookMarkModel * _Nonnull obj2) {
        if ([obj1.timestamp integerValue] < [obj2.timestamp integerValue]) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }] mutableCopy];
    
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:KEY_PATH(t_arr.firstObject, chapterSort) ascending:YES];
    t_arr = [[t_arr sortedArrayUsingDescriptors:@[sort1]] mutableCopy];
    
    self.dataSourceArray = t_arr;
    [self.mainTableView reloadData];
    
    [self.mainTableView ly_endLoading];
}

- (void)createSubviews {
    [self setBasicLayout];
    
    [self.view addSubview:self.mainTableView];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.contentInset = UIEdgeInsetsMake(0, 0, PUB_TABBAR_OFFSET, 0);
    [self.mainTableView registerClass:[WXYZ_BookMarkCell class] forCellReuseIdentifier:@"Identifier"];
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self setEmptyOnView:self.mainTableView title:@"暂无书签记录" buttonTitle:@"" tapBlock:^{}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_BookMarkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier" forIndexPath:indexPath];
    [cell setBookMarkModel:self.dataSourceArray[indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_BookMarkModel *t_model = self.dataSourceArray[indexPath.row];
    [self.dataSourceArray removeObjectAtIndex:indexPath.row];
    if (@available(iOS 11.0, *)) {
        [tableView performBatchUpdates:^{
            [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationLeft];
        } completion:^(BOOL finished) {
            [WXYZ_ProductionReadRecordManager removeBookMark:t_model];
            [tableView ly_endLoading];
        }];
    } else {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [WXYZ_ProductionReadRecordManager removeBookMark:t_model];
            [tableView ly_endLoading];
        }];
        [tableView beginUpdates];
        [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
        [CATransaction commit];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WXYZ_BookMarkModel *t_model = self.dataSourceArray[indexPath.row];
    
    if (self.isReader) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNOtification_Book_Mark object:@{[NSString stringWithFormat:@"%zd", t_model.chapterSort] : [NSString stringWithFormat:@"%zd", t_model.specificIndex]}];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        WXYZ_BookReaderViewController *vc = [[WXYZ_BookReaderViewController alloc] initWithSpecificIndex:t_model.specificIndex chapterSort:t_model.chapterSort];
        vc.bookModel = self.bookModel;
        vc.book_id = self.bookModel.production_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHalfMargin;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHalfMargin)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)setBasicLayout {
    [self hiddenNavigationBar:YES];
}

@end
