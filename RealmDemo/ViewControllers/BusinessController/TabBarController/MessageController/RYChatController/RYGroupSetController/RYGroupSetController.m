//
//  RYGroupSetController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RYGroupSetController.h"
#import "RYGroupSetUserCell.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "RCDSelectPersonController.h"
#import "RYGroupSetName.h"

@interface RYGroupSetController ()<UITableViewDelegate,UITableViewDataSource,RYGroupSetUserDelegate,RYGroupSetNameDelegate,RBQFetchedResultsControllerDelegate,MuliteSelectDelegate> {
    UITableView *_tableView;
    UserManager *_userManager;
    RBQFetchedResultsController *_userDiscussFetchedResultsController;//讨论组数据监听
    NSMutableArray<RCUserInfo*> *_rCUserArr;//当前聊天的人员
    BOOL _isUserEdit;//是否是用户编辑模式
    RCDiscussion *_currRCDiscussion;//当前讨论组
}

@end

@implementation RYGroupSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rCUserArr = [@[] mutableCopy];
    _isUserEdit = NO;
    _userManager = [UserManager manager];
    _userDiscussFetchedResultsController = [_userManager createUserDiscusFetchedResultsController];
    _userDiscussFetchedResultsController.delegate = self;
    //获取当前讨论组
    [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId success:^(RCDiscussion* discussion) {
        if (discussion) {
            _currRCDiscussion = discussion;
            self.title = discussion.discussionName;
            //填充用户信息
            for (NSString *targetId in discussion.memberIdList) {
                NSMutableArray *array = [_userManager getEmployeeArr];
                Employee * emp = [Employee new];
                for (Employee *employee in array) {
                    if(employee.user_no == [targetId integerValue]) {
                        emp = employee;
                        break;
                    }
                }
                RCUserInfo *user = [RCUserInfo new];
                user.portraitUri = emp.avatar;
                user.name = emp.user_real_name;
                user.userId = targetId;
                [_rCUserArr addObject:user];
            }
            [_tableView reloadData];
        }
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UserDiscuss *userDiscuss in [_userManager getUserDiscussArr]) {
                if([userDiscuss.discuss_id isEqualToString:self.targetId]) {
                    [_userManager deleteUserDiscuss:userDiscuss];
                    [UserHttp delUserDiscuss:_userManager.user.user_no discussId:self.targetId handler:^(id data, MError *error) {
                        [self.navigationController.view showFailureTips:@"讨论组不存在，已删除!"];
                        [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3] animated:YES];
                    }];
                    break;
                }
            }
        });
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"RYGroupSetUserCell" bundle:nil] forCellReuseIdentifier:@"RYGroupSetUserCell"];
    [self.view addSubview:_tableView];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT).size.width, 45)];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 42, 90/2)];
    [button setBackgroundColor:[UIColor colorWithRed:240/255.f green:80/255.f blue:80/255.f alpha:1]];
    [button setTitle:@"删除并退出" forState:UIControlStateNormal];
    [button setCenter:CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    _tableView.tableFooterView = view;
    // Do any additional setup after loading the view.
}
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [_tableView reloadData];
}
- (void)buttonAction:(UIButton*)btn {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"删除并且退出讨论组？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[RCIMClient sharedRCIMClient] quitDiscussion:self.targetId success:^(RCDiscussion *discussion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (UserDiscuss *userDiscuss in [_userManager getUserDiscussArr]) {
                    if([userDiscuss.discuss_id isEqualToString:discussion.discussionId]) {
                        [_userManager deleteUserDiscuss:userDiscuss];
                        break;
                    }
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } error:nil];
    }];
    [alertVC addAction:cancle];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark --
#pragma mark -- RYGroupSetUserDelegate
//某个人员删除按钮被点击
- (void)RYGroupSetUserDelete:(RCUserInfo*)user {
    [[RCIMClient sharedRCIMClient] removeMemberFromDiscussion:_currRCDiscussion.discussionId userId:user.userId success:^(RCDiscussion *discussion) {
        [_rCUserArr removeObject:user];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    } error:nil];
}
//某个人员被点击
- (void)RYGroupSetUserClicked {
    if(_isUserEdit) {
        _isUserEdit = NO;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//删除按钮被点击
- (void)RYGroupSetDeleteClicked {
    _isUserEdit = !_isUserEdit;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}
//增加按钮被点击
- (void)RYGroupSetAddClicked {
    //人员多选界面
    RCDSelectPersonController *muliteSelect = [RCDSelectPersonController new];
    //得到当前讨论组的的编号
    int companyNo = 0;
    NSMutableArray *array = [@[] mutableCopy];
    for (RCUserInfo *rCUserInfo in _rCUserArr) {
        NSMutableArray *tempArray = [_userManager getEmployeeArr];
        Employee * emp = [Employee new];
        for (Employee *employee in tempArray) {
            if(employee.user_no == [rCUserInfo.userId integerValue]) {
                emp = employee;
                companyNo = employee.company_no;
                break;
            }
        }
        [array addObject:emp];
    }
    muliteSelect.companyNo = companyNo;
    muliteSelect.selectedEmployees = [array mutableCopy];
    muliteSelect.delegate = self;
    [self.navigationController pushViewController:muliteSelect animated:YES];
}
#pragma mark --
#pragma mark -- MuliteSelectDelegate
-(void)muliteSelect:(NSMutableArray<RCUserInfo *> *)employeeArr rCDSelect:(RCDSelectPersonController *)rCDSelect{
    if(employeeArr.count == 0) return;
    //选择的再加上自己已经有的，然后调用接口
    _rCUserArr = employeeArr;
    NSMutableArray *array = [@[] mutableCopy];
    for (RCUserInfo *rCUserInfo in _rCUserArr) {
        [array addObject:rCUserInfo.userId];
    }
    [[RCIMClient sharedRCIMClient] addMemberToDiscussion:self.targetId userIdList:array success:^(RCDiscussion *discussion) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [_tableView reloadData];
        });
    } error:nil];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   if(section == 0)
       return 1;
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        int count = 0;//一共几个人
        //如果是圈主才能增加删除人
        if([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:_currRCDiscussion.creatorId]) {
            count = (int)_rCUserArr.count + 2;
        } else {
            //如果开放了成员邀请，可以增加人
            if(_currRCDiscussion.inviteStatus == 0) {
                count = (int)_rCUserArr.count + 1;
            } else {//不是圈主。又没有开放权限，就只有这么多人
                count = (int)_rCUserArr.count;
            }
        }
        int line = count / 5;
        if(count % 5 != 0)
            line ++;
        return 10 + line * ((MAIN_SCREEN_WIDTH - 50) / 5 + 20) + (line - 1) * 10;
    }
    if(indexPath.row == 2) {
        //圈主才能开放成员邀请权限
        if([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:_currRCDiscussion.creatorId])
            return 44;
        return 0.01f;
    }
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        RYGroupSetUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RYGroupSetUserCell" forIndexPath:indexPath];
        cell.currRCDiscussion = _currRCDiscussion;
        cell.isUserEdit = _isUserEdit;
        cell.data = _rCUserArr;
        cell.delegate = self;
        return cell;
    }
    UITableViewCell *cell = nil;
    if(indexPath.row == 0) {//讨论组名称
        cell = [tableView dequeueReusableCellWithIdentifier:@"NameCell"];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NameCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.row == 5) {//清除聊天记录
        cell = [tableView dequeueReusableCellWithIdentifier:@"ClearCell"];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClearCell"];
        }
    } else {//有开关的
        cell = [tableView dequeueReusableCellWithIdentifier:@"HaveSwitchCell"];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HaveSwitchCell"];
            UISwitch *sw = [[UISwitch alloc] init];
            cell.accessoryView = sw;
            [sw addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if (indexPath.row == 0) {//讨论组名称
        cell.textLabel.text = @"讨论组名称";
        cell.detailTextLabel.text = _currRCDiscussion.discussionName;
    } else if (indexPath.row == 1) {//保存讨论组到通讯录
        UISwitch *sw = (id)cell.accessoryView;
        sw.tag = 1001;
        sw.hidden = NO;
        BOOL have = NO;
        for (UserDiscuss *userDiscuss in [_userManager getUserDiscussArr]) {
            if([userDiscuss.discuss_id isEqualToString:self.targetId]) {
                have = YES;
                break;
            }
        }
        sw.on = have;
        cell.textLabel.text = @"保存讨论组到通讯录";
    } else if(indexPath.row == 2) {//开放成员邀请
        UISwitch *sw = (id)cell.accessoryView;
        sw.tag = 1002;
        sw.hidden = NO;
        sw.on = !_currRCDiscussion.inviteStatus;//0表示允许，1表示不允许
        cell.textLabel.text = @"开放成员邀请";
        if(![[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:_currRCDiscussion.creatorId]) {
            sw.hidden = YES;
            cell.textLabel.text = @"";
        }
    } else if(indexPath.row == 3) {//置顶
        UISwitch *sw = (id)cell.accessoryView;
        sw.hidden = NO;
        sw.tag = 1003;
        cell.textLabel.text = @"置顶聊天";
        RCConversation *conversation =
        [[RCIMClient sharedRCIMClient] getConversation:ConversationType_DISCUSSION targetId:self.targetId];
        sw.on = conversation.isTop;
    } else if(indexPath.row == 4) {//新消息通知
        UISwitch *sw = (id)cell.accessoryView;
        sw.tag = 1004;
        sw.hidden = NO;
        cell.textLabel.text = @"新消息通知";
        [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_DISCUSSION targetId:self.targetId success:^(RCConversationNotificationStatus nStatus) {
            if(DO_NOT_DISTURB == nStatus)
                sw.on = NO;
            else
                sw.on = YES;
        } error:nil];
    } else if(indexPath.row == 5) {//清除聊天记录
        cell.textLabel.text = @"清除聊天记录";
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) return;
    if(indexPath.row == 0) {//讨论组名称修改
        RYGroupSetName *set = [RYGroupSetName new];
        set.data = _currRCDiscussion;
        set.delegate = self;
        [self.navigationController pushViewController:set animated:YES];
    } else if (indexPath.row == 5) {//清除聊天记录
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否删除历史记录？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_DISCUSSION targetId:self.targetId];
            if(self.delegate && [self.delegate respondsToSelector:@selector(rYGroupClearChatNote)]) {
                [self.delegate rYGroupClearChatNote];
            }
        }];
        [alertVC addAction:cancle];
        [alertVC addAction:ok];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
#pragma mark -- 
#pragma mark -- RYGroupSetNameDelegate
- (void)RYGroupSetName:(NSString *)name {
    [self.navigationController.view showLoadingTips:@""];
    [[RCIMClient sharedRCIMClient] setDiscussionName:self.targetId name:name success:^{
        _currRCDiscussion.discussionName = name;
        self.title = name;
        if(self.delegate && [self.delegate respondsToSelector:@selector(rYGroupSetNameChange:)]) {
            [self.delegate rYGroupSetNameChange:name];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            [self.navigationController.view dismissTips];
        });
    } error:nil];

}
- (void)switchClicked:(UISwitch*)sw {
    if(sw.tag == 1001) {//保存讨论组到通讯录
        if(sw.on == YES) {//添加
            [UserHttp addUserDiscuss:_userManager.user.user_no discussId:_currRCDiscussion.discussionId discussTitle:_currRCDiscussion.discussionName handler:^(id data, MError *error) {
                if(error) return ;
                UserDiscuss *currDiscuss = [UserDiscuss new];
                [currDiscuss mj_setKeyValues:data];
                [_userManager addUserDiscuss:currDiscuss];
            }];
        } else {//删除
            [UserHttp delUserDiscuss:_userManager.user.user_no discussId:_currRCDiscussion.discussionId handler:^(id data, MError *error) {
                for (UserDiscuss *userDiscuss in [_userManager getUserDiscussArr]) {
                    if([userDiscuss.discuss_id isEqualToString:_currRCDiscussion.discussionId]) {
                        [_userManager deleteUserDiscuss:userDiscuss];
                        break;
                    }
                }
            }];
        }
    } else if (sw.tag == 1002) {//开放成员邀请
        [[RCIMClient sharedRCIMClient] setDiscussionInviteStatus:_currRCDiscussion.discussionId isOpen:!sw.on success:^{
            _currRCDiscussion.inviteStatus = !sw.on;
        } error:nil];
    } else if (sw.tag == 1003) {//置顶聊天
        [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_DISCUSSION targetId:self.targetId isTop:sw.on];
    } else {//新消息通知
        [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_DISCUSSION targetId:self.targetId isBlocked:!sw.on success:^(RCConversationNotificationStatus nStatus) {
            [_tableView reloadData];
        } error:nil];
    }
}
@end
