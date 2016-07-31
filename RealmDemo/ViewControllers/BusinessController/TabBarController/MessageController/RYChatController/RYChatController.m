//
//  RYChatController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RYChatController.h"
#import "WebNonstandarViewController.h"
#import "BushDetailController.h"
#import "MineInfoEditController.h"
#import "IdentityManager.h"
#import "RYGroupSetController.h"

@interface RYChatController ()<RCChatSessionInputBarControlDelegate,RYGroupSetDelegate> {
    UserManager *_userManager;
}

@end

@implementation RYChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    [self setMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    self.chatSessionInputBarControl.delegate = self;
    NSString *nameStr = @"ic_group";
    if(self.conversationType == ConversationType_PRIVATE) {
        nameStr = @"ic_person";
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:nameStr] style:UIBarButtonItemStylePlain target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    if (self.conversationType == ConversationType_PRIVATE) {
        //查看对方详情（网页）
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.showNavigationBar = NO;
        webViewcontroller.applicationUrl  = [NSString stringWithFormat:@"%@/Personal/index?showGuid=%@&userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,self.friends.user_guid,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:YES];
    } else if (self.conversationType == ConversationType_GROUP){
        //查看圈子详情
        UserManager *manager = [UserManager manager];
        Company *tempCompany = nil;
        for (Company *company in [manager getCompanyArr]) {
            if(company.company_no == self.targetId.intValue) {
                tempCompany = company;
                break;
            }
        }
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"MineView" bundle:nil];
        BushDetailController * con = [story instantiateViewControllerWithIdentifier:@"BushDetailController"];
        con.data = tempCompany;
        [self.navigationController pushViewController:con animated:YES];
    } else if (self.conversationType == ConversationType_DISCUSSION){
        //讨论组设置 需要自己做
        RYGroupSetController *set = [RYGroupSetController new];
        set.targetId = self.targetId;
        set.delegate = self;
        [self.navigationController pushViewController:set animated:YES];
    }
}
#pragma mark --
#pragma mark -- RYGroupSetDelegate
//讨论组名字修改了
- (void)rYGroupSetNameChange:(NSString*)name {
    self.title = name;
}
//讨论组清除聊天记录
- (void)rYGroupClearChatNote {
    [self.conversationMessageCollectionView reloadData];
}
#pragma mark - OVerride RongCloud Methods
//头像点击事件
- (void) didTapCellPortrait:(NSString*)userId{
    if (self.conversationType != ConversationType_PRIVATE){
        if ([userId isEqualToString:@(_userManager.user.user_no).stringValue]) {//自己头像被点击  编辑
            MineInfoEditController *mineInfoVC = [[MineInfoEditController alloc] init];
            [self.navigationController pushViewController:mineInfoVC animated:YES];
        }
        else{//别人头像被点击 查看
            NSMutableArray *array = [_userManager getEmployeeArr];
            Employee * emp = [Employee new];
            for (Employee *employee in array) {
                if(employee.user_no == [userId integerValue]) {
                    emp = employee;
                    break;
                }
            }
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.showNavigationBar = NO;
            webViewcontroller.applicationUrl  = [NSString stringWithFormat:@"%@/Personal/index?showGuid=%@&userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,emp.user_guid,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        }
    }
}
#pragma mark - RCChatSessionInputBarControlDelegate
-(void)keyboardWillHide{
    [self.chatSessionInputBarControl setFrame:CGRectMake(self.chatSessionInputBarControl.frame.origin.x, MAIN_SCREEN_HEIGHT - self.chatSessionInputBarControl.frame.size.height + 20, self.chatSessionInputBarControl.frame.size.width, self.chatSessionInputBarControl.frame.size.height)];
    self.conversationMessageCollectionView.frame = CGRectMake(self.chatSessionInputBarControl.frame.origin.x, self.chatSessionInputBarControl.frame.origin.y, self.chatSessionInputBarControl.frame.size.width, self.chatSessionInputBarControl.frame.origin.y - 44 - 20);
}
@end
