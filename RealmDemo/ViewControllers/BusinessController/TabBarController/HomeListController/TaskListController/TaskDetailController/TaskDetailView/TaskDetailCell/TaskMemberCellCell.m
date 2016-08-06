//
//  TaskMemberCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskMemberCellCell.h"
#import "TaskModel.h"

@interface TaskMemberCellCell () {
    NSTimer *_timer;
    CGFloat _currScrollWidth;
    CGFloat _maxScrollWidth;
}
@property (weak, nonatomic) IBOutlet UIScrollView *memberImage;
@property (weak, nonatomic) IBOutlet UILabel *memberNumber;

@end

@implementation TaskMemberCellCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrollMember) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1000000]];
    // Initialization code
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    if([NSString isBlank:model.members_avatar]) {
        self.memberNumber.text = [NSString stringWithFormat:@"%d人",0];
        return;
    }
    NSArray *array = [model.members_avatar componentsSeparatedByString:@","];
    self.memberNumber.text = [NSString stringWithFormat:@"%d人",array.count];
    CGFloat currX = 0;
    for (NSString *str in array) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(currX, 0, 29, 29)];
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 14.5;
        [imageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        [self.memberImage addSubview:imageView];
        
        currX += 31;
    }
    self.memberImage.contentSize = CGSizeMake(currX, 29);
    if(currX > self.memberImage.frame.size.width) {
        _maxScrollWidth = currX - self.memberImage.frame.size.width;
        _currScrollWidth = 10;
        [_timer setFireDate:[NSDate dateWithTimeIntervalSince1970:0]];
    } else  {
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1000000]];
    }
}
- (void)scrollMember {
    [UIView animateWithDuration:1 animations:^{
        _memberImage.contentOffset = CGPointMake(_currScrollWidth, 0);
    }];
    _currScrollWidth += 10;
    if(_currScrollWidth > _maxScrollWidth)
        _currScrollWidth = 10;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
