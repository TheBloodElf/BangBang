//
//  AttachPicView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AttachPicView.h"
#import "Attachment.h"
#import "AttachPicCell.h"

@interface AttachPicView ()<UITableViewDelegate,UITableViewDataSource,AttachmentSelectDelegate> {
    NSMutableArray<Attachment*> *_albumPic;//相机胶卷图片
    NSMutableArray<Attachment*> *_downPic;//已下载图片
    
    UITableView *_tableView;//表格视图
}

@end

@implementation AttachPicView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _downPic = [@[] mutableCopy];
        _albumPic = [@[] mutableCopy];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"AttachPicCell" bundle:nil] forCellReuseIdentifier:@"AttachPicCell"];
        [self addSubview:_tableView];
        //这里把本地相机胶卷读取出来
        ALAssetsLibrary *libary = [ALAssetsLibrary new];
        [libary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            //便利完成了
            if(group == nil) {
                *stop = YES;
            } else {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result == nil && index == NSNotFound) {
                        dispatch_main_sync_safe(^(){
                            [_tableView reloadData];
                        });
                        *stop = YES;
                    } else {
                        NSString *type = [result valueForProperty:ALAssetPropertyType];
                        if([type isEqualToString:ALAssetTypePhoto]) {
                            Attachment *attachment = [Attachment new];
                            attachment.fileData = UIImageJPEGRepresentation([UIImage imageWithCGImage:(result.aspectRatioThumbnail)],0.5);
                            attachment.fileName = [NSString stringWithFormat:@"%@.png",@([NSDate date].timeIntervalSince1970 * 1000)];
                            [_albumPic addObject:attachment];
                        }
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
            
        }];
    }
    return self;
}
- (void)dataDidChange {
    _downPic = self.data;
    [_tableView reloadData];
}
#pragma mark -- AttachmentSelectDelegate
- (void)attachmentDidSelect:(Attachment *)attachment {
    if(self.delegate && [self.delegate respondsToSelector:@selector(attachmentDidSelect:)]) {
        [self.delegate attachmentDidSelect:attachment];
    }
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int lines = 0;
    if(indexPath.section == 0) {
        lines = (int)_albumPic.count / 4;
        if(_albumPic.count % 4 != 0)
            lines ++;
    } else {
        lines = (int)_downPic.count / 4;
        if(_downPic.count % 4 != 0)
            lines ++;
    }
    return lines * (MAIN_SCREEN_WIDTH / 4);
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"相机胶卷";
    return @"已下载图片";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttachPicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachPicCell" forIndexPath:indexPath];
    if(indexPath.section == 0)
        cell.data = _albumPic;
    else
        cell.data = _downPic;
    cell.delegate = self;
    return cell;
}
@end
