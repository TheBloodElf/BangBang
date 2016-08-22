//
//  BushSearchCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "BushSearchCell.h"
#import "UserManager.h"

@interface BushSearchCell  () {
    UserManager *_userManager;
    Employee *_employee;
}
@property (weak, nonatomic) IBOutlet UIImageView *bushImage;
@property (weak, nonatomic) IBOutlet UILabel *bushName;
@property (weak, nonatomic) IBOutlet UILabel *bushType;
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;

@end

@implementation BushSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.bushImage zy_cornerRadiusRoundingRect];
    self.joinBtn.layer.cornerRadius = 5.f;
    self.joinBtn.clipsToBounds = YES;
    [self.joinBtn addTarget:self action:@selector(joinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _userManager = [UserManager manager];
    // Initialization code
}
- (void)joinBtnClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(bushSearchCellJoin:)]) {
        [self.delegate bushSearchCellJoin:self.data];
    }
}
- (void)dataDidChange {
    Company *model = self.data;
    [self.bushImage sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.bushName.text = model.company_name;
    self.bushType.text = [model companyTypeStr];
    [self.joinBtn setTitle:@"申请加入" forState:UIControlStateNormal];
    [self.joinBtn setBackgroundColor:[UIColor grayColor]];
    self.joinBtn.enabled = YES;
    //获取在当前圈子中的自己（员工）
    _employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:model.company_no];
    if(_employee.id == 0)
        return;
    //查看自己的状态 设置按钮
    if (_employee.status == 1) {
        [self.joinBtn setTitle:@"已经加入" forState:UIControlStateNormal];
        self.joinBtn.enabled = NO;
        [self.joinBtn setBackgroundColor:[UIColor lightGrayColor]];
    }else if (_employee.status == 0){
        [self.joinBtn setTitle:@"等待加入" forState:UIControlStateNormal];
        self.joinBtn.enabled = NO;
        [self.joinBtn setBackgroundColor:[UIColor lightGrayColor]];
    }else if (_employee.status == 4){
        [self.joinBtn setTitle:@"离职中" forState:UIControlStateNormal];
        self.joinBtn.enabled = NO;
        [self.joinBtn setBackgroundColor:[UIColor lightGrayColor]];
    }
}

@end
