//
//  XAddrBookCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "XAddrBookCell.h"
#import "UserManager.h"

@interface XAddrBookCell () {
    UserManager *_userManager;
}
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userDert;
@property (weak, nonatomic) IBOutlet UIImageView *headView;

@end

@implementation XAddrBookCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.userImage zy_cornerRadiusRoundingRect];
    _userManager = [UserManager manager];
    // Initialization code
}

- (void)dataDidChange {
    Employee * employee = self.data;
    //#BANG-550 隐藏帮帮号
//    self.userName.text = [NSString stringWithFormat:@"%@(%@)", employee.user_real_name,employee.user_name];
    self.userName.text = [NSString stringWithFormat:@"%@", employee.real_name];
    if([NSString isBlank:employee.departments])
        self.userDert.text = @"无部门信息";
    else
        self.userDert.text = employee.departments;
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:employee.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    //是不是当前圈子的管理员
    self.headView.hidden = YES;
    User *user = _userManager.user;
    if([employee.user_guid isEqualToString:user.currCompany.admin_user_guid])
        self.headView.hidden = NO;
}
@end
