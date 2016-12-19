//
//  MoreSelectView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/14.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MoreSelectView.h"

@interface MoreSelectView ()<UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;//展示数据的表格视图
}

@end

@implementation MoreSelectView

- (void)setupUI {
    self.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    self.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    self.layer.shadowRadius = 8;//阴影半径，默认3
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.layer.cornerRadius = 5.f;
    self.clipsToBounds = YES;
    self.hidden = YES;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _selectArr.count * 45) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
    [self hideSelectView];
    [_tableView reloadData];
}
- (void)showSelectView {
    WeakSelf(weakSelf)
    [UIView animateWithDuration:0.2 animations:^{
       weakSelf.alpha = 1;
    } completion:^(BOOL finished) {
       weakSelf.hidden = NO;
       weakSelf.isHide = NO;
    }];
}
- (void)hideSelectView {
    WeakSelf(weakSelf)
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        weakSelf.hidden = YES;
        weakSelf.isHide = YES;
    }];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _selectArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 45)];
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16];
        label.tag = 10001;
        [cell.contentView addSubview:label];
    }
    UILabel *label = (id)[cell.contentView viewWithTag:10001];
    label.text = _selectArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(moreSelectIndex:)]) {
        [self.delegate moreSelectIndex:(int)(indexPath.row)];
    }
    [self hideSelectView];
}
@end
