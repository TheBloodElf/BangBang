//
//  SelectDelayDateView.m
//  RealmDemo
//
//  Created by Mac on 2016/11/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SelectDelayDateView.h"
//头部的高度
#define Top_Label_Height 40.f
//cell的高度
#define Table_View_Cell_Height 35.f

@interface SelectDelayDateView ()<UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;
    NSArray<NSString*> *_dateStrArr;
}

@end

@implementation SelectDelayDateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dateStrArr = @[@"5分钟",@"10分钟",@"30分钟",@"1小时",@"2小时",@"1天",@"2天"];
        //创建头部
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, Top_Label_Height)];
        topLabel.text = @"推迟时间";
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:topLabel];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, Top_Label_Height, MAIN_SCREEN_WIDTH, 0.5)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:line];
        //创建表格视图
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Top_Label_Height + 0.5, MAIN_SCREEN_WIDTH, frame.size.height - Top_Label_Height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
        UIButton *customBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        customBtn.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, Table_View_Cell_Height);
        [customBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [customBtn setTitle:@"自定义" forState:UIControlStateNormal];
        customBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [customBtn addTarget:self action:@selector(customClicked:) forControlEvents:UIControlEventTouchUpInside];
//        _tableView.tableFooterView = customBtn;
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
    }
    return self;
}
- (void)customClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectCustom)]) {
        [self.delegate selectCustom];
    }
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Table_View_Cell_Height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dateStrArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, Table_View_Cell_Height)];
        label.font = [UIFont systemFontOfSize:15];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 10001;
        [cell.contentView addSubview:label];
    }
    
    UILabel *label = (id)[cell.contentView viewWithTag:10001];
    label.text = _dateStrArr[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int second = 0;
    switch (indexPath.row) {
        case 0: second = 5 * 60; break;
        case 1: second = 10 * 60; break;
        case 2: second = 30 * 60; break;
        case 3: second = 1 * 60 * 60; break;
        case 4: second = 2 * 60 * 60; break;
        case 5: second = 24 * 60 * 60; break;
        case 6: second = 2 * 24 * 60 * 60; break;
        default: break;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectDelayDate:)]) {
        [self.delegate selectDelayDate:second];
    }
}
@end
