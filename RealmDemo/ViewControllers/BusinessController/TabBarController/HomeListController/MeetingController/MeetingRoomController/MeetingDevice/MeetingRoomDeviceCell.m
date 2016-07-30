//
//  MeetingRoomDeviceCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingRoomDeviceCell.h"
#import "MeetingDeviceCell.h"

@interface MeetingRoomDeviceCell ()<UICollectionViewDelegate,UICollectionViewDataSource> {
    UICollectionView *_collectionView;
    NSArray<MeetingRoomModel*> *_meetingRoomArr;
}

@end

@implementation MeetingRoomDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((MAIN_SCREEN_WIDTH - 40) / 3.f, 80);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 100) collectionViewLayout:layout];
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 0, 0);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"MeetingDeviceCell" bundle:nil] forCellWithReuseIdentifier:@"MeetingDeviceCell"];
    [self.contentView addSubview:_collectionView];
}

- (void)dataDidChange {
    _meetingRoomArr = self.data;
    [_collectionView reloadData];
}
#pragma mark -- UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _meetingRoomArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MeetingDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MeetingDeviceCell" forIndexPath:indexPath];
    cell.meetingRoomModel = self.meetingRoomModel;
    cell.data = _meetingRoomArr[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingDeviceSelect:)]) {
        [self.delegate MeetingDeviceSelect:_meetingRoomArr[indexPath.row]];
    }
}

@end
