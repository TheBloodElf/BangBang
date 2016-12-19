//
//  BushManagerCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "BushManagerCell.h"
#import "UIImageView+WebCache.h"
#import "Company.h"

@interface BushManagerCell  ()

@property (weak, nonatomic) IBOutlet UIImageView *bushImage;
@property (weak, nonatomic) IBOutlet UITextView *bushName;
@property (weak, nonatomic) IBOutlet UILabel *bushTitle;


@end

@implementation BushManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.bushImage zy_cornerRadiusAdvance:5.f rectCornerType:UIRectCornerAllCorners];
    self.bushName.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.bushName.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // Initialization code
}
- (void)dataDidChange {
    Company *model = self.data;
    //设置模型值 cell没有重新新建  所以里面写着不是很规范 不要模仿
    [self.bushImage sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    NSString *name = [NSString stringWithFormat:@"%@（%@）",model.company_name,@(model.company_no)];
    self.bushName.text = name;
    self.bushTitle.text = [NSString stringWithFormat:@"%@",model.companyTypeStr];
}

@end
