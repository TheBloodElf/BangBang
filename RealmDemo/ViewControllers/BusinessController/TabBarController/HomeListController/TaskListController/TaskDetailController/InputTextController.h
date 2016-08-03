//
//  InputTextController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^InputTextBlock) (NSString*);
@interface InputTextController : UIViewController

@property (nonatomic, copy) InputTextBlock inputTextBlock;

@end
