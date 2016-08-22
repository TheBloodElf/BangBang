//
//  RequestManagerCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/5.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "RequestManagerCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface RequestManagerCell  ()

@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *refuseBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userAvater;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation RequestManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.userAvater zy_cornerRadiusRoundingRect];
    
    self.agreeBtn.layer.cornerRadius = 5.f;
    self.agreeBtn.clipsToBounds = YES;
    
    self.refuseBtn.layer.cornerRadius = 5;
    self.refuseBtn.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    Employee *employee = self.data;
    [self.userAvater sd_setImageWithURL:[NSURL URLWithString:employee.avatar] placeholderImage:[UIImage imageNamed:@"soft_logo_icon"]];
    self.userName.text = employee.real_name;
    if(employee.status == 0) {//如果是加入申请
        self.detailLabel.text = [NSString stringWithFormat:@"加入理由:%@",employee.join_reason];
    } else {//如果是退出申请
        self.detailLabel.text = [NSString stringWithFormat:@"退出理由:%@",employee.leave_reason];
    }
}
- (IBAction)refuseBtnClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(requestManagerAgree:)]) {
        [self.delegate requestManagerRefuse:self.data];
    }
}
- (IBAction)agreeBtnClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(requestManagerRefuse:)]) {
        [self.delegate requestManagerAgree:self.data];
    }
}


@end
