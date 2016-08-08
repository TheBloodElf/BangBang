//
//  CreateBushController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CreateBushController.h"
#import "CreateBushModel.h"
#import "UserHttp.h"
#import "UserManager.h"

@interface CreateBushController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate,UITextFieldDelegate> {
    CreateBushModel *_createBushModel;//创建圈子传给服务器的模型
    UserManager *_userManager;//用户管理器
}

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;//圈子名字
@property (weak, nonatomic) IBOutlet UITableViewCell *imageCell;//圈子图标
@property (weak, nonatomic) IBOutlet UITableViewCell *typeCell;//圈子类型
@property (weak, nonatomic) IBOutlet UITableViewCell *detailCell;//圈子详情

@end

@implementation CreateBushController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建圈子";
    _userManager = [UserManager manager];
    //初始化 设置模型的默认值
    _createBushModel = [CreateBushModel new];
    _createBushModel.type = 6;
    _createBushModel.typeString = @"其他";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightButtonClicked:)];
}
- (void)rightButtonClicked:(UIBarButtonItem*)item {
    //创建圈子前腰看看是否满足提交的条件
    if ([NSString isBlank:_createBushModel.name]) {
        [self.navigationController.view showFailureTips:@"圈子名称不能为空"];
    } else if (!_createBushModel.hasImage) {
        [self.navigationController.view showFailureTips:@"请选择圈子图标"];
    } else {
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp createCompany:_createBushModel.name userGuid:_userManager.user.user_guid image:_createBushModel.hasImage companyType:(int)_createBushModel.type handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            Company *company = [[Company alloc] initWithJSONDictionary:data];
            [self.navigationController.view showSuccessTips:@"创建成功"];
            [_userManager addCompany:company];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}
#pragma mark --
#pragma mark -- TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    _createBushModel.name = textField.text;
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //当输入框失去第一响应者就把输入框的内容赋给模型变量
    _createBushModel.name = textField.text;
}
#pragma mark --
#pragma mark -- TextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //当输入框失去第一响应者就把输入框的内容赋给模型变量
    _createBushModel.detail = textView.text;
}
- (void)textViewDidChange:(UITextView *)textView
{
    //textview没有占位符 这里我们自己做了一个
    //根据textview的内容判断是不是需要隐藏占位符
    //占位符是一个标签 tag为1001
    if(textView.text.length == 0)
        [[self.detailCell viewWithTag:1001] setHidden:NO];
    else
        [[self.detailCell viewWithTag:1001] setHidden:YES];
}

#pragma mark --
#pragma mark -- TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {//圈子名字
            UITextField *text = [self.nameCell viewWithTag:1000];
            text.delegate = self;
            text.text = _createBushModel.name;
            return self.nameCell;
        } else if (indexPath.row == 1) {//圈子图标
            UIImageView *image = [self.imageCell viewWithTag:1000];
            if(_createBushModel.hasImage)
                image.image = _createBushModel.hasImage;
            return self.imageCell;
        } else {//圈子类型
            UILabel *label = [self.typeCell viewWithTag:1000];
            label.text = _createBushModel.typeString;
            return self.typeCell;
        }
    }
    UITextView *text = [self.detailCell viewWithTag:1000];
    text.delegate = self;
    if(_createBushModel.detail)//圈子详情
        text.text = _createBushModel.detail;
    return self.detailCell;
}
- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //先取消cell的选中效果
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    //使当前页面不能编辑 触发失去第一响应者的回调 给模型赋值
    [self.view endEditing:YES];
    if(indexPath.section == 1)
        return;
    if(indexPath.row == 0)
        return;
    if (indexPath.row == 1) {
        //选择圈子图标
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"上传图标" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cacleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *selectAction = [UIAlertAction actionWithTitle:@"选取相册图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:picker animated:YES completion:nil];
        }];
        UIAlertAction *creamAction = [UIAlertAction actionWithTitle:@"现在拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {//看当前设备是否能够拍照
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            } else {
                [self.navigationController.view showFailureTips:@"无法打开相机"];
            }
        }];
        [alertVC addAction:cacleAction];
        [alertVC addAction:selectAction];
        [alertVC addAction:creamAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        //选择圈子类型
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"圈子类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cacleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *selectAction1 = [UIAlertAction actionWithTitle:@"国有企业" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _createBushModel.type = 1;
            _createBushModel.typeString = @"国有企业";
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        UIAlertAction *selectAction2 = [UIAlertAction actionWithTitle:@"私有企业" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _createBushModel.type = 2;
            _createBushModel.typeString = @"私有企业";
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        UIAlertAction *selectAction3 = [UIAlertAction actionWithTitle:@"事业单位或社会团体" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _createBushModel.type = 3;
            _createBushModel.typeString = @"事业单位或社会团体";
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        UIAlertAction *selectAction4 = [UIAlertAction actionWithTitle:@"中外合资" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _createBushModel.type = 4;
            _createBushModel.typeString = @"中外合资";
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        UIAlertAction *selectAction5 = [UIAlertAction actionWithTitle:@"外商独资" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _createBushModel.type = 5;
            _createBushModel.typeString = @"外商独资";
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        UIAlertAction *selectAction6 = [UIAlertAction actionWithTitle:@"其他" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _createBushModel.type = 6;
            _createBushModel.typeString = @"其他";
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [alertVC addAction:cacleAction];
        [alertVC addAction:selectAction1];
        [alertVC addAction:selectAction2];
        [alertVC addAction:selectAction3];
        [alertVC addAction:selectAction4];
        [alertVC addAction:selectAction5];
        [alertVC addAction:selectAction6];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    _createBushModel.hasImage = image;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
