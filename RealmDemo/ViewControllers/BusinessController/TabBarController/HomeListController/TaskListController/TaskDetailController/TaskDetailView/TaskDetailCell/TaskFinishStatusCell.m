//
//  TaskFinishStatusCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/9/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskFinishStatusCell.h"
#import "UserManager.h"

@interface TaskFinishStatusCell ()

@property (weak, nonatomic) IBOutlet UIImageView *finishAvater;
@property (weak, nonatomic) IBOutlet UILabel *finishName;
@property (weak, nonatomic) IBOutlet UILabel *finishTime;
@property (weak, nonatomic) IBOutlet UILabel *finishLabel;

@end

@implementation TaskFinishStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.finishAvater zy_cornerRadiusRoundingRect];
    // Initialization code
}

- (void)dataDidChange {
    TaskModel *taskModel = self.data;
    Employee *lastEmployee = [Employee new];
    for (Employee *employee in [[UserManager manager] getEmployeeWithCompanyNo:taskModel.company_no status:-1]) {
        if([employee.employee_guid isEqualToString:taskModel.updatedby]) {
            lastEmployee = employee;
            break;
        }
    }
    [self.finishAvater sd_setImageWithURL:[NSURL URLWithString:lastEmployee.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.finishName.text = lastEmployee.real_name;
    //算出时间
    NSDate *finishDate = [NSDate dateWithTimeIntervalSince1970:taskModel.updatedon_utc / 1000];
    self.finishTime.text = [NSString stringWithFormat:@"%d-%d-%d",finishDate.year,finishDate.month,finishDate.day];
    NSMutableAttributedString *finishStr;
    if(taskModel.status == 1) {//新建
    } else if(taskModel.status == 2) {//进行中
    } else if(taskModel.status == 4) {//待审批
        NSString *finishLabelStr = [@"[提交理由]" stringByAppendingString:taskModel.finish_comment];
        finishStr = [[NSMutableAttributedString alloc] initWithString:finishLabelStr];
        [finishStr setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} range:NSMakeRange(0, 6)];
    } else if(taskModel.status == 6) {//审批拒绝
        NSString *finishLabelStr = [@"[拒绝理由]" stringByAppendingString:taskModel.approve_comment];
        finishStr = [[NSMutableAttributedString alloc] initWithString:finishLabelStr];
        [finishStr setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(0, 6)];
    } else if(taskModel.status == 7) {//已完成
        NSString *finishLabelStr = [@"[完成情况]" stringByAppendingString:taskModel.approve_comment];
        finishStr = [[NSMutableAttributedString alloc] initWithString:finishLabelStr];
        [finishStr setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} range:NSMakeRange(0, 6)];
    } else if(taskModel.status == 8) {//已终止
        NSString *finishLabelStr = [@"[终止理由]" stringByAppendingString:taskModel.approve_comment];
        finishStr = [[NSMutableAttributedString alloc] initWithString:finishLabelStr];
        [finishStr setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(0, 6)];
    }
    self.finishLabel.attributedText = finishStr;
}

@end
