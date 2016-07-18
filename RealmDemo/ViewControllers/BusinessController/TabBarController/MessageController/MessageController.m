//
//  MessageController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MessageController.h"
#import "MoreSelectView.h"
#import "MuliteSelectController.h"
#import "RYChatController.h"

@interface MessageController ()<MoreSelectViewDelegate,MuliteSelectDelegate> {
    MoreSelectView *_moreSelectView;
}

@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会话消息";
    //设置融云聊天界面
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP),@(ConversationType_DISCUSSION)]];
    [self setConversationAvatarStyle:RC_USER_AVATAR_CYCLE];
    self.conversationListTableView.tableFooterView = [UIView new];
    
    _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 15, 64, 100, 40)];
    _moreSelectView.selectArr = @[@"发起讨论"];
    [_moreSelectView setupUI];
    _moreSelectView.delegate = self;
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.frostedViewController.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    if(_moreSelectView.isHide == YES)
        [_moreSelectView showSelectView];
    else
        [_moreSelectView hideSelectView];
}
#pragma mark -- 
#pragma mark --  MoreSelectViewDelegate
- (void)moreSelectIndex:(int)index {
    MuliteSelectController *mulite = [MuliteSelectController new];
    mulite.delegate = self;
    mulite.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mulite animated:YES];
}
#pragma mark --
#pragma mark -- MuliteSelectDelegate
- (void)muliteSelect:(NSMutableArray<Employee *> *)employeeArr {
    //转换成融云的用户对象
    NSMutableArray<NSString*> *nameArr = [@[] mutableCopy];
    NSMutableArray<NSString*> *idArr = [@[] mutableCopy];
    for (Employee *employee in employeeArr) {
        [nameArr addObject:employee.real_name];
        [idArr addObject:@(employee.user_no).stringValue];
    }
    [[RCIMClient sharedRCIMClient] createDiscussion:[nameArr componentsJoinedByString:@","] userIdList:idArr success:^(RCDiscussion *discussion) {
        RYChatController *chat =[[RYChatController alloc] init];
        chat.targetId                      = discussion.discussionId;
        chat.conversationType              = ConversationType_DISCUSSION;
        chat.title                         = [nameArr componentsJoinedByString:@","];
        chat.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chat animated:YES];
    } error:nil];
}
//点击进入会话界面
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {
    [self.conversationListTableView deselectRowAtIndexPath:indexPath animated:YES];
    if(conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL)  {
        RYChatController *chat = [RYChatController new];
        chat.conversationType =model.conversationType;; //会话类型，这里设置为 PRIVATE 即发起单聊会话。
        chat.targetId = model.targetId; // 接收者的 targetId，这里为举例。
        chat.title = model.conversationTitle; // 会话的 title
        chat.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chat animated:YES];
    } else if(conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        MessageController *temp = [[MessageController alloc] init];
        NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        temp.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }
}
@end
