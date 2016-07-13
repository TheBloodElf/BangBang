//
//  EAIntroViewController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EAIntroViewController;
//展示4张欢迎图的控制器
@protocol EAIntroViewDelegate <NSObject>

- (void)eAIntroViewDidFinish:(EAIntroViewController*)eAIntro;

@end

@interface EAIntroViewController : UIViewController

@property (nonatomic, weak) id<EAIntroViewDelegate> delegate;

@end
