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
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.hidden = YES;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _selectArr.count * 40) style:UITableViewStylePlain];
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
    return 40.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _selectArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _selectArr[indexPath.row];
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
