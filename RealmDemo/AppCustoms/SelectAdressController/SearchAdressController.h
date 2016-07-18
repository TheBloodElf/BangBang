//
//  SearchAdressController.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/24.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchAdressDelegate <NSObject>

- (void)searchAdress:(AMapPOI*)aMapPOI;

@end

@interface SearchAdressController : UIViewController

@property (nonatomic, strong) AMapPOIAroundSearchRequest *searchPOIRequest;//周边搜索句柄
@property (nonatomic, weak) id<SearchAdressDelegate> delegate;

@end
