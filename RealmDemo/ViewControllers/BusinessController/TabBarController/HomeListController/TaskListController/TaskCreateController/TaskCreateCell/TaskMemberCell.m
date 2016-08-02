//
//  TaskMemberCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskMemberCell.h"
#import "Employee.h"

@interface TaskMemberCell ()
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *memberImage;

@end

@implementation TaskMemberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.detailLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)dataDidChange {
    NSMutableArray<Employee*> *employeeArr = self.data;
    if(employeeArr.count == 0) {
        self.detailLabel.text = @"请选择";
        self.memberImage.hidden = YES;
    } else {
        self.memberImage.hidden = NO;
        //清除子类
        for (UIView *view in self.memberImage.subviews) {
            [view removeFromSuperview];
        }
        
        //算出最多能显示多少人
        int maxCount = (MAIN_SCREEN_WIDTH - 61 - 38 - 5) / 30;
        if(employeeArr.count <= 6) {//如果能在左边显示完
            self.detailLabel.hidden = YES;
            for (int index = 0;index < employeeArr.count; index ++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 * index, 1.5, 27, 27)];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[employeeArr[index] avatar]] placeholderImage:[UIImage imageNamed:@""]];
                imageView.layer.cornerRadius = 13.5f;
                imageView.clipsToBounds = YES;
                [self.memberImage addSubview:imageView];
            }
        } else {
            if(employeeArr.count <= maxCount) {//如果能在整个长度显示完
                self.detailLabel.hidden = YES;
                for (int index = 0;index < employeeArr.count; index ++) {
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 * index, 1.5, 27, 27)];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:[employeeArr[index] avatar]] placeholderImage:[UIImage imageNamed:@""]];
                    imageView.layer.cornerRadius = 13.5f;
                    imageView.clipsToBounds = YES;
                    [self.memberImage addSubview:imageView];
                }
            } else {
                for (int index = 0;index < 6; index ++) {//只显示前面6个
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 * index, 1.5, 27, 27)];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:[employeeArr[index] avatar]] placeholderImage:[UIImage imageNamed:@""]];
                    imageView.layer.cornerRadius = 13.5f;
                    imageView.clipsToBounds = YES;
                    [self.memberImage addSubview:imageView];
                }
                self.detailLabel.hidden = NO;
                self.detailLabel.text = [NSString stringWithFormat:@"等%d人",employeeArr.count];
            }
        }
    }
}

@end
