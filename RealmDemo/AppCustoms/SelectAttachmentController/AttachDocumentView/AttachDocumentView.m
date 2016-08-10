//
//  AttachDocumentView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AttachDocumentView.h"
#import "AttachDocumentCell.h"
#import "Attachment.h"

@interface AttachDocumentView ()<UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;
    NSMutableArray<Attachment*> *_wordAttachmentArr;
    NSMutableArray<Attachment*> *_excelAttachmentArr;
    NSMutableArray<Attachment*> *_pdfAttachmentArr;
}

@end

@implementation AttachDocumentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"AttachDocumentCell" bundle:nil] forCellReuseIdentifier:@"AttachDocumentCell"];
        [self addSubview:_tableView];
        _wordAttachmentArr = [@[] mutableCopy];
        _excelAttachmentArr = [@[] mutableCopy];
        _pdfAttachmentArr = [@[] mutableCopy];
    }
    return self;
}
- (void)dataDidChange {
    for (Attachment *attachment in self.data) {
        if([@"doc.docx" rangeOfString:attachment.fileName.pathExtension options:NSCaseInsensitiveSearch].location != NSNotFound)
            [_wordAttachmentArr addObject:attachment];
        else if([@"xls.xlsx" rangeOfString:attachment.fileName.pathExtension options:NSCaseInsensitiveSearch].location != NSNotFound)
            [_excelAttachmentArr addObject:attachment];
        else
            [_pdfAttachmentArr addObject:attachment];
    }
    [_tableView reloadData];
}
#pragma mark -- UITableViewDelegate
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"WORD";
    if(section == 1)
        return @"EXCEL";
    return @"PDF";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return _wordAttachmentArr.count;
    if(section == 1)
        return _excelAttachmentArr.count;
    return _pdfAttachmentArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttachDocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachDocumentCell" forIndexPath:indexPath];
    if(indexPath.section == 0)
        cell.data = _wordAttachmentArr[indexPath.row];
    else if(indexPath.section == 1)
        cell.data = _excelAttachmentArr[indexPath.row];
    else
        cell.data = _pdfAttachmentArr[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Attachment * attachment = nil;
    if(indexPath.section == 0) {
        attachment = _wordAttachmentArr[indexPath.row];
    } else if (indexPath.section == 1) {
        attachment = _excelAttachmentArr[indexPath.row];
    } else {
        attachment = _pdfAttachmentArr[indexPath.row];
    }
    attachment.isSelected = !attachment.isSelected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(attachmentDidSelect:)]) {
        [self.delegate attachmentDidSelect:attachment];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
@end
