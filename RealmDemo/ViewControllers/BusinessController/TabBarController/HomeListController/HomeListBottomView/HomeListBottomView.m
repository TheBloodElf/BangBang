//
//  HomeListBottomView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HomeListBottomView.h"
#import "BottomViewItem.h"

@interface HomeListBottomView ()<BottomViewItemDelegate> {
    NSMutableArray<BottomItemModel*> *_modelArr;//模型数组
}

@end

@implementation HomeListBottomView
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //创建模型
        _modelArr = [@[] mutableCopy];
        NSArray *nameArr = @[@"公告",@"动态",@"签到",@"审批",@"帮邮", @"会议",@"投票",@"通用审批"];
        NSArray *imageNameArr = @[@"home_0",@"home_1",@"home_2",@"home_3",@"home_4",@"home_5",@"home_6",@"home_7"];
        for (NSInteger index = 0; index < nameArr.count; index ++) {
            BottomItemModel *model = [BottomItemModel new];
            model.index = index;
            model.titleName = nameArr[index];
            model.imageName = imageNameArr[index];
            [_modelArr addObject:model];
        }
        //创建视图
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:lineView];
        CGFloat itemWidth = frame.size.width / 4.f;
        CGFloat itemHeight = frame.size.width / 4.f;
        for (NSInteger index = 0; index < _modelArr.count; index ++) {
            BottomViewItem *item = [[BottomViewItem alloc] initWithFrame:CGRectMake(itemWidth * (index % 4), itemHeight * (index / 4), itemWidth, itemHeight)];
            item.delegate = self;
            item.data = _modelArr[index];
            [self addSubview:item];
        }
    }
    return self;
}
#pragma mark --
#pragma mark -- BottomViewItemDelegate
- (void)bottomItemClicked:(BottomItemModel *)item {
    if(self.delegate && [self.delegate respondsToSelector:@selector(homeListBottomClicked:)]) {
        [self.delegate homeListBottomClicked:item.index];
    }
}
@end
