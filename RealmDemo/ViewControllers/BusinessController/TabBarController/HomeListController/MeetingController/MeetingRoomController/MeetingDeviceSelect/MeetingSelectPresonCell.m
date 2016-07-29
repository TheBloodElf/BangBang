//
//  MeetingSelectPresonCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingSelectPresonCell.h"
#import "Employee.h"

@interface MeetingSelectPresonCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation MeetingSelectPresonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    Employee *employee = self.data;
    if(![NSString isBlank:employee.real_name])
        self.nameLabel.text = employee.real_name;
}
@end
