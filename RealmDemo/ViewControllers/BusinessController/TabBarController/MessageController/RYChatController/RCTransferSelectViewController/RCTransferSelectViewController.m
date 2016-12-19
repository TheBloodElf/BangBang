//
//  RCTransferSelectViewController.m
//  BangBang
//
//  Created by PC-002 on 16/1/7.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "RCTransferSelectViewController.h"
#import "UserManager.h"
#import "RCTransferDiscussCell.h"
#import "RCTransferCompanyCell.h"
#import "RCTransferEmployeeCell.h"

@interface RCTransferSelectViewController ()<UITableViewDelegate,UITableViewDataSource> {
    UserManager *_userManager;
    NSMutableArray<UserDiscuss*> *_userDiscussArr;//用户讨论组
    NSMutableArray<Company*> *_companyArr;//用户圈子
    NSMutableArray<Employee*> *_employeeArr;//用户成员
    UITableView *_tableView;
}
@property (nonatomic,strong)RCMessageContent *messageContent;
@end

@implementation RCTransferSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分享给";
    _userManager = [UserManager manager];
    _userDiscussArr = [_userManager getUserDiscussArr];
    _employeeArr = [_userManager getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no status:5];
    _companyArr = [@[] mutableCopy];
    for (Company *company in [_userManager getCompanyArr]) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
        if(employee.status == 1 || employee.status == 4) {
            [_companyArr addObject:company];
        }
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"RCTransferCompanyCell" bundle:nil] forCellReuseIdentifier:@"RCTransferCompanyCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"RCTransferDiscussCell" bundle:nil] forCellReuseIdentifier:@"RCTransferDiscussCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"RCTransferEmployeeCell" bundle:nil] forCellReuseIdentifier:@"RCTransferEmployeeCell"];
    [self.view addSubview:_tableView];
}
- (void)dataDidChange {
    self.messageContent = self.data;
}
#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
        return _employeeArr.count;
    if(section == 1)
        return _companyArr.count;
    return _userDiscussArr.count;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"当前圈子成员";
    if(section == 1)
        return @"群组";
    return @"讨论组";
}
-(UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"RCTransferEmployeeCell" forIndexPath:indexPath];
    }
    else if(indexPath.section == 1) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"RCTransferCompanyCell" forIndexPath:indexPath];
    } else {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"RCTransferDiscussCell" forIndexPath:indexPath];
    }
    
    if(indexPath.section == 0)
        cell.data = _employeeArr[indexPath.row];
    else if(indexPath.section == 1)
        cell.data = _companyArr[indexPath.row];
    else
        cell.data = _userDiscussArr[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController.view showLoadingTips:@""];
    RCConversationType transferType = 0;
    NSString *targetId = nil;
    if(indexPath.section == 0) {//成员
        transferType = ConversationType_PRIVATE;
        targetId = @([_employeeArr[indexPath.row] user_no]).stringValue;
    } else if(indexPath.section == 1){//圈子
        transferType = ConversationType_GROUP;
        targetId = @([_companyArr[indexPath.row] company_no]).stringValue;
    } else {//讨论组
        transferType = ConversationType_DISCUSSION;
        targetId = [_userDiscussArr[indexPath.row] discuss_id];
    }
    
    if ([_messageContent isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *textMessage = (RCTextMessage *)_messageContent;
        [[RCIM sharedRCIM] sendMessage:transferType targetId:targetId content:_messageContent pushContent:@"" pushData:textMessage.content success:^(long messageId){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController.view dismissTips];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }error:^(RCErrorCode nErrorCode, long messageId){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController.view showFailureTips:@"发送失败"];
            });
        }];
    }else if ([_messageContent isMemberOfClass:[RCImageMessage class]] || [_messageContent isMemberOfClass:[RCRichContentMessage class]]){
        [[RCIM sharedRCIM] sendMessage:transferType targetId:targetId content:_messageContent pushContent:@"" pushData:[_messageContent isMemberOfClass:[RCImageMessage class]]?@"[图片]" : @"[图文]" success:^(long messageId){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController.view dismissTips];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }error:^(RCErrorCode nErrorCode, long messageId){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController.view dismissTips];
                [self.navigationController.view showFailureTips:@"发送失败"];
            });
        }];
    }
}
@end
