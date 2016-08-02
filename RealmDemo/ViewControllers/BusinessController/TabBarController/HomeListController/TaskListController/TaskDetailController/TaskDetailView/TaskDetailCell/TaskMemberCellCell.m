//
//  TaskMemberCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskMemberCellCell.h"
#import "TaskModel.h"

@interface TaskMemberCellCell ()
@property (weak, nonatomic) IBOutlet UIScrollView *memberImage;
@property (weak, nonatomic) IBOutlet UILabel *memberNumber;

@end

@implementation TaskMemberCellCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    NSArray *array = [model.members_avatar componentsSeparatedByString:@","];
    self.memberNumber.text = [NSString stringWithFormat:@"%d人",array.count];
    CGFloat currX = 0;
    for (NSString *str in array) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(currX, 0, 29, 29)];
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 14.5;
        [imageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@""]];
        [self.memberImage addSubview:imageView];
        
        currX += 31;
    }
    self.memberImage.contentSize = CGSizeMake(currX, 29);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
