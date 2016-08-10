//
//  AttachOtherView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AttachOtherView.h"
#import "Attachment.h"
#import "AttachOtherCell.h"

@interface AttachOtherView ()<UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;
    NSMutableArray<Attachment*> *_musicAttachmentArr;
}

@end

@implementation AttachOtherView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _musicAttachmentArr = [@[] mutableCopy];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"AttachOtherCell" bundle:nil] forCellReuseIdentifier:@"AttachOtherCell"];
        [self addSubview:_tableView];
    }
    return self;
}
-(void)dataDidChange {
    _musicAttachmentArr = self.data;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _musicAttachmentArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttachOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachOtherCell" forIndexPath:indexPath];
    cell.data = _musicAttachmentArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _musicAttachmentArr[indexPath.row].isSelected = !_musicAttachmentArr[indexPath.row].isSelected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(attachmentDidSelect:)]) {
        [self.delegate attachmentDidSelect:_musicAttachmentArr[indexPath.row]];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
@end
