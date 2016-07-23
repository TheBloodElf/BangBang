//
//  RCTransferSelectViewController.m
//  BangBang
//
//  Created by PC-002 on 16/1/7.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "RCTransferSelectViewController.h"
#import "Employee.h"
#import "UserDiscuss.h"
#import "Company.h"

@interface RCTransferSelectViewController () {
    NSMutableArray *contentArr;
}

@end

@implementation RCTransferSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    self.title = @"分享给";
//    self.tableViewCellHeight = 60.0;
    
    [self loadData];
}
-(void)loadData{
//    [contentArr removeAllObjects];
//    NSArray *allEmployees = [Employee valueListFromDB];
//    NSArray *users = [Employee userFriends:allEmployees overUser:[BSEngine currentUserId]];
//    contentArr = [Employee sortData:users];
//    //转发到圈子
//    NSArray *companyList = [UserCompanyModel myCompanyListFromDB];
//    NSMutableArray *firstSectionData = [contentArr firstObject];
//    for (UserCompanyModel* model in companyList) {
//        //把圈子构造成员工实体 不用再定义一个两者统一的实体
//        Employee *companyEmployee = [Employee new];
//        companyEmployee.user_real_name = [NSString stringWithFormat:@"工作圈:%@",model.company_name];
//        companyEmployee.avatar = model.logo;
//        companyEmployee.user_no = model.company_no;
//        //sex 1001表示圈子聊天
//        companyEmployee.sex = @"1001";
//        [firstSectionData insertObject:companyEmployee atIndex:0];
//    }
    //转发到讨论组
//    NSArray *discussList = [UserDiscuss valueListFromDB];
//    for (UserDiscuss *model in discussList) {
//        //把讨论组构造成员工实体 不用再定义一个两者统一的实体
//        Employee *companyEmployee = [Employee new];
//        companyEmployee.user_real_name = [NSString stringWithFormat:@"讨论组:%@",model.discuss_title];
//        companyEmployee.avatar = model.discuss_title;
//        companyEmployee.user_no = model.discuss_id;
//        //sex 1002表示圈子聊天
//        companyEmployee.sex = @"1002";
//        [firstSectionData insertObject:companyEmployee atIndex:0];
//    }
}
#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return contentArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[contentArr objectAtIndex:section] count];
}

-(UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"RCDTransferPersonCell";
//    BaseTableViewCell *cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (!cell) {
//        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    [cell setUserInteractionEnabled:YES];
//    Employee *employee = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    cell.textLabel.text = employee.user_real_name;
//    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:employee.avatar] placeholderImage:[Globals getImageUserHeadDefault]];
//    [cell update:^(NSString *name) {
//        // 调整位置
//        [cell autoAdjustText];
//        cell.imageView.layer.cornerRadius = cell.imageView.height/2;
//        cell.textLabel.width = [cell.textLabel.text sizeWithFont:cell.textLabel.font maxWidth:cell.width maxNumberLines:1].width;
//        cell.textLabel.top = cell.height/2 - cell.textLabel.height/2;
//    }];
//    
//    return cell;
    return nil;
}
-(void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    Employee *employee = [[contentArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    //清楚里面的用户数据
//    _messageContent.senderUserInfo = nil;
//    RCConversationType transferType = ConversationType_PRIVATE;
//    if ([employee.sex isEqualToString:@"1001"]) {
//        transferType = ConversationType_GROUP;
//    }else if ([employee.sex isEqualToString:@"1002"]){
//        transferType = ConversationType_DISCUSSION;
//    }
//    
//    if ([_messageContent isMemberOfClass:[RCTextMessage class]]) {
//        RCTextMessage *textMessage = (RCTextMessage *)_messageContent;
//        [[RCIM sharedRCIM] sendMessage:transferType targetId:employee.user_no content:_messageContent pushContent:@"" pushData:textMessage.content success:^(long messageId){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showSuccessText:@"发送成功"];
//                [self popViewController];
//            });
//            
//            XYFLog(@"xyf------转发消息到圈子成功！");
//        }error:^(RCErrorCode nErrorCode, long messageId){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showSuccessText:@"发送失败"];
//            });
//            XYFLog(@"xyf------转发消息到圈子失败！");
//        }];
//    }else if ([_messageContent isMemberOfClass:[RCImageMessage class]] || [_messageContent isMemberOfClass:[RCRichContentMessage class]]){
//        
//        [[RCIM sharedRCIM] sendMessage:transferType targetId:employee.user_no content:_messageContent pushContent:@"" pushData:[_messageContent isMemberOfClass:[RCImageMessage class]]?@"[图片]" : @"[图文]" success:^(long messageId){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showSuccessText:@"发送成功"];
//                [self popViewController];
//            });
//            XYFLog(@"xyf------转发消息到圈子成功！");
//        }error:^(RCErrorCode nErrorCode, long messageId){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showSuccessText:@"发送失败"];
//            });
//            XYFLog(@"xyf------转发消息到圈子失败！");
//        }];
//    }
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    if ([[contentArr objectAtIndex:section] count] > 0 && section != 0) {
        return 20;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    if ([[contentArr objectAtIndex:section] count] > 0 && section != 0) {
        UIImageView *bkgImageView = [[UIImageView alloc] init];
        bkgImageView.backgroundColor = [UIColor colorWithRed:219 green:219 blue:219 alpha:1];
        UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 120, 14)];
        tLabel.textColor=[UIColor blackColor];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.text = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        [bkgImageView addSubview:tLabel];
        return bkgImageView;
    }
    return nil;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)sender{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (contentArr.count > 0 && section != 0) {
        return [[[UILocalizedIndexedCollation currentCollation]sectionTitles] objectAtIndex:section];
    }else{
        return nil;
    }
}

@end
