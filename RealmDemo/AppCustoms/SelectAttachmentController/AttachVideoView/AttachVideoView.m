//
//  AttachVideoView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AttachVideoView.h"
#import "Attachment.h"
#import "AttachVideoCell.h"

@interface AttachVideoView ()<UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;
    NSMutableArray<Attachment*> *_iphoneAttachmentArr;//手机视频
    NSMutableArray<Attachment*> *_downAttachmentArr;//本地已下载视频
}

@end

@implementation AttachVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _iphoneAttachmentArr = [@[] mutableCopy];
        _downAttachmentArr = [@[] mutableCopy];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"AttachVideoCell" bundle:nil] forCellReuseIdentifier:@"AttachVideoCell"];
        [self addSubview:_tableView];
        //这里用PHAsset来获取视频数据 ALAsset显得很无力了。。。
        PHFetchResult *voideResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
        PHImageManager *manager = [PHImageManager defaultManager];
        // 视频请求对象
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        [voideResult enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
            Attachment *attachment = [Attachment new];
            attachment.fileCreateDate = obj.creationDate;
            [manager requestAVAssetForVideo:obj options:options resultHandler:^(AVAsset * asset, AVAudioMix * audioMix, NSDictionary * info) {
                attachment.fileName = [asset mj_keyValues][@"propertyListForProxy"][@"name"];
                attachment.fileSize = [[asset mj_keyValues][@"propertyListForProxy"][@"moop"] length];
                attachment.fileData = [asset mj_keyValues][@"propertyListForProxy"][@"moop"];
                [_iphoneAttachmentArr addObject:attachment];
            }];
        }];
    }
    return self;
}
- (void)dataDidChange {
    _downAttachmentArr = self.data;
    [_tableView reloadData];
}
#pragma mark -- UITableViewDelegate
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"手机视频";
    return @"已下载视频";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return _iphoneAttachmentArr.count;
    return _downAttachmentArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttachVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachVideoCell" forIndexPath:indexPath];
    if(indexPath.section == 0)
        cell.data = _iphoneAttachmentArr[indexPath.row];
    else
        cell.data = _downAttachmentArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Attachment *attachMent = nil;
    if(indexPath.section == 0)
        attachMent = _iphoneAttachmentArr[indexPath.row];
    else
        attachMent = _downAttachmentArr[indexPath.row];
    attachMent.isSelected = !attachMent.isSelected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(attachmentDidSelect:)]) {
        [self.delegate attachmentDidSelect:attachMent];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
@end
