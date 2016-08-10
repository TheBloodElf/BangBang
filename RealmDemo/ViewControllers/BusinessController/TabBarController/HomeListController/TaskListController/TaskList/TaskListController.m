//
//  TaskListController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskListController.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "InchargeTaskView.h"
#import "CreateTaskView.h"
#import "MemberTaskView.h"
#import "FinishTaskView.h"
#import "TaskCreateController.h"
#import "TaskDetailController.h"
#import "MoreSelectView.h"

@interface TaskListController ()<UIScrollViewDelegate,TaskClickedDelegate,MoreSelectViewDelegate> {
    UserManager *_userManager;
    UISegmentedControl *_topSegmentedControl;//上面的分段控件
    UIScrollView *_bottomScrollView;//下面的滚动视图
    MoreSelectView *_moreSelectView;//多选视图
}

@end

@implementation TaskListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务列表";
    _userManager = [UserManager manager];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _topSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"负责的",@"委派的",@"知悉的",@"已完结"]];
    _topSegmentedControl.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 35);
    _topSegmentedControl.tintColor = [UIColor siginColor];
    [_topSegmentedControl addTarget:self action:@selector(segmentedClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_topSegmentedControl];
    
    _bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 35, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64 - 35)];
    _bottomScrollView.delegate = self;
    _bottomScrollView.showsVerticalScrollIndicator = NO;
    _bottomScrollView.showsHorizontalScrollIndicator = NO;
    _bottomScrollView.bounces = NO;
    _bottomScrollView.pagingEnabled = YES;
    _bottomScrollView.scrollEnabled = NO;
    _bottomScrollView.contentSize = CGSizeMake(4 * _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height);
    [self.view addSubview:_bottomScrollView];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor siginColor];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self.data isEqualToString:@"YES"]) return;
    self.data = @"YES";
    
    //负责的
    InchargeTaskView *incharge = [[InchargeTaskView alloc] initWithFrame:CGRectMake(0, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    incharge.delegate = self;
    [_bottomScrollView addSubview:incharge];
    //委派的
    CreateTaskView *create = [[CreateTaskView alloc] initWithFrame:CGRectMake(_bottomScrollView.frame.size.width, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    create.delegate = self;
    [_bottomScrollView addSubview:create];
    //知悉的
    MemberTaskView *member = [[MemberTaskView alloc] initWithFrame:CGRectMake(2 * _bottomScrollView.frame.size.width, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    member.delegate = self;
    [_bottomScrollView addSubview:member];
    //完结的
    FinishTaskView *finish = [[FinishTaskView alloc] initWithFrame:CGRectMake(3 * _bottomScrollView.frame.size.width, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    finish.delegate = self;
    [_bottomScrollView addSubview:finish];
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    //如果本圈子的任务数量为0 就从服务器获取一次
    NSArray *array = [_userManager getTaskArr:_userManager.user.currCompany.company_no];
    if(array.count == 0) {
        [self.navigationController.view showLoadingTips:@"同步任务..."];
        [UserHttp getTaskList:employee.employee_guid handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSMutableArray<TaskModel*> *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                TaskModel *model = [[TaskModel alloc] initWithJSONDictionary:dic];
                model.descriptionStr = dic[@"description"];
                [array addObject:model];
            }
            [_userManager updateTask:array companyNo:_userManager.user.currCompany.company_no];
            [self.navigationController.view showSuccessTips:@"同步成功"];
        }];
    }
    
    //创建多选视图
    _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100, 0, 100, 80)];
    _moreSelectView.selectArr = @[@"添加任务",@"同步任务"];
    _moreSelectView.delegate = self;
    [_moreSelectView setupUI];
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    
    //显示第几个
    if(self.type == 0)
        _topSegmentedControl.selectedSegmentIndex = 0;
    else
        _topSegmentedControl.selectedSegmentIndex = 1;
    [self segmentedClicked:_topSegmentedControl];
}
- (void)moreClicked:(UIBarButtonItem*)item {
    if(_moreSelectView.isHide)
        [_moreSelectView showSelectView];
    else
        [_moreSelectView hideSelectView];
}
#pragma mark --
#pragma mark -- MoreSelectViewDelegate
- (void)moreSelectIndex:(int)index {
    if(index == 0) {
        //添加任务
        TaskCreateController *create = [TaskCreateController new];
        [self.navigationController pushViewController:create animated:YES];
    } else {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
        [self.navigationController.view showLoadingTips:@"同步任务..."];
        [UserHttp getTaskList:employee.employee_guid handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSMutableArray<TaskModel*> *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                TaskModel *model = [[TaskModel alloc] initWithJSONDictionary:dic];
                model.descriptionStr = dic[@"description"];
                [array addObject:model];
            }
            [_userManager updateTask:array companyNo:_userManager.user.currCompany.company_no];
            [self.navigationController.view showSuccessTips:@"同步成功"];
        }];
    }
}
#pragma mark -- TaskClickedDelegate
- (void)taskClicked:(TaskModel *)taskModel {
    //查看任务详情
    TaskDetailController *detail = [TaskDetailController new];
    detail.data = taskModel;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)segmentedClicked:(UISegmentedControl*)control {
    if(!_moreSelectView.isHide)
        [_moreSelectView hideSelectView];
    if(control.selectedSegmentIndex == 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(moreClicked:)];
    else
        self.navigationItem.rightBarButtonItems = nil;
    [_bottomScrollView setContentOffset:CGPointMake(control.selectedSegmentIndex * _bottomScrollView.frame.size.width, 0) animated:NO];
    
    [self.view endEditing:YES];
}
#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = (scrollView.contentOffset.x + scrollView.frame.size.width / 2.f) / scrollView.frame.size.width;
    [_topSegmentedControl setSelectedSegmentIndex:index];
    if(index == 0)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(moreClicked:)];
    else
        self.navigationItem.rightBarButtonItems = nil;
    
    [self.view endEditing:YES];
}
@end
