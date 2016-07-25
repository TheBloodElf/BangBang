//
//  RYGroupSetUserCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RYGroupSetUserDelegate <NSObject>
//某个人员删除按钮被点击
- (void)RYGroupSetUserDelete:(id)user;
//某个人员被点击
- (void)RYGroupSetUserClicked;
//删除按钮被点击
- (void)RYGroupSetDeleteClicked;
//增加按钮被点击
- (void)RYGroupSetAddClicked;

@end

@interface RYGroupSetUserCell : UITableViewCell

@property (nonatomic, assign) BOOL isUserEdit;//是否处于编辑状态
@property (nonatomic, strong) RCDiscussion *currRCDiscussion;
@property (nonatomic, weak) id<RYGroupSetUserDelegate> delegate;

@end
