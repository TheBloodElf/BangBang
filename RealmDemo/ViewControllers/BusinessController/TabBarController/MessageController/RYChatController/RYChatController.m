//
//  RYChatController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RYChatController.h"
#import "UserManager.h"
#import "BushDetailController.h"

@interface RYChatController ()<RCChatSessionInputBarControlDelegate>

@end

@implementation RYChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    self.chatSessionInputBarControl.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)rightClicked:(UIBarButtonItem*)item {
    if (self.conversationType == ConversationType_PRIVATE) {
        //查看对方详情（网页）
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
    }
}
#pragma mark - RCChatSessionInputBarControlDelegate
-(void)keyboardWillHide{
    [self.chatSessionInputBarControl setFrame:CGRectMake(self.chatSessionInputBarControl.frame.origin.x, MAIN_SCREEN_HEIGHT - self.chatSessionInputBarControl.frame.size.height + 20, self.chatSessionInputBarControl.frame.size.width, self.chatSessionInputBarControl.frame.size.height)];
    self.conversationMessageCollectionView.frame = CGRectMake(self.chatSessionInputBarControl.frame.origin.x, self.chatSessionInputBarControl.frame.origin.y, self.chatSessionInputBarControl.frame.size.width, self.chatSessionInputBarControl.frame.origin.y - 44 - 20);
}
@end
