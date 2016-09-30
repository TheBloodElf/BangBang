//
//  LeftMenuCell.m
//  RealmDemo
//
//  Created by Mac on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LeftMenuCell.h"
#import "UserManager.h"

@interface LeftMenuCell ()

@property (weak, nonatomic) IBOutlet UIImageView *companyImage;
@property (weak, nonatomic) IBOutlet UILabel *companyName;

@end

@implementation LeftMenuCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.companyImage zy_cornerRadiusAdvance:15.f rectCornerType:UIRectCornerAllCorners];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)dataDidChange {
    UserManager *_userManager = [UserManager manager];
    Company *company = self.data;
    [self.companyImage sd_setImageWithURL:[NSURL URLWithString:company.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.companyName.text = company.company_name;
    self.companyName.textColor = [UIColor whiteColor];
    if(_userManager.user.currCompany.company_no == company.company_no) {
        self.companyName.textColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    }
}
@end
