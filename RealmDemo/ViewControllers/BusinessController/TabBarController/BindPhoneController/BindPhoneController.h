//
//  BindPhoneController.h
//  RealmDemo
//
//  Created by Mac on 2016/11/11.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BindPhoneDelegate <NSObject>

- (void)bindPhoneClicked;
- (void)bindCancle;

@end
//提示用户绑定手机
@interface BindPhoneController : UIViewController

@property (nonatomic, weak) id<BindPhoneDelegate> delegate;

@end
