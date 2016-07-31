//
//  WebNonstandarViewController.h
//  BangBang
//
//  Created by Xiaoyafei on 15/9/29.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

/**
 *  网页显示的都是这个类来加载
 */
@interface WebNonstandarViewController : UIViewController

@property (nonatomic,strong) NSString *applicationUrl;//需要加载的url
@property (nonatomic,assign) BOOL showNavigationBar;//是否使用自带的导航条

@end
