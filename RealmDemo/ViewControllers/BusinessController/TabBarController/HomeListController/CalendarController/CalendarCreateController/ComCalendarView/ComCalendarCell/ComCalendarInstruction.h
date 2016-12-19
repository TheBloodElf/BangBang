//
//  ComCalendarInstruction.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ComCalendarInstructionDelegate <NSObject>
//详情超长了
- (void)comCalendarInstructionOverLength;

@end

@interface ComCalendarInstruction : UITableViewCell

@property (nonatomic, weak) id<ComCalendarInstructionDelegate> delegate;

@end
