//
//  TaskAttenmentCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskAttenmentCell.h"

@interface TaskAttenmentCell ()
@property (weak, nonatomic) IBOutlet UILabel *attenmentName;

@end

@implementation TaskAttenmentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    UIImage *photo = self.data;
    self.attenmentName.text = [NSString stringWithFormat:@"IMG%@.jpg %dM",@([NSDate date].timeIntervalSince1970),UIImageJPEGRepresentation(photo, 1).length / 1024];
}
- (IBAction)deleteClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(TaskAttenmentDelete:)]) {
        [self.delegate TaskAttenmentDelete:self.data];
    }
}

@end
