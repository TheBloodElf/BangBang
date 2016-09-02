//
//  MineInfoEditController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/20.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "MineInfoEditController.h"
#import "UserManager.h"
#import "UserHttp.h"

#import "ChangeUserName.h"
#import "ChangeUserBBH.h"
#import "ChangeUserDetail.h"

@interface MineInfoEditController ()<UITableViewDelegate,UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate,ChangeUserInfoDelegate,RBQFetchedResultsControllerDelegate>
{
    UITableView *_tableView;//表格视图
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据监听
}

@end

@implementation MineInfoEditController
#pragma mark --
#pragma mark -- ControllerLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
    _userManager = [UserManager manager];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //如果是从业务的根视图进来的 就隐藏导航
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [_tableView reloadData];
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section ? 2 : 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置重用标识符
    static NSString *topIdentifier = @"topIdentifier";
    static NSString *bottomIdentifier = @"bottomIdentifier";
    User *currUser = [UserManager manager].user;
    //创建cell
    UITableViewCell *cell = nil;
    if(indexPath.row == 0 && indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"topIdentifier"];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topIdentifier];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 30 - 15 - 30, 5, 40, 40)];
            [imageView zy_cornerRadiusRoundingRect];
            [cell.contentView addSubview:imageView];
            imageView.tag = 1000;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"bottomIdentifier"];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:bottomIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    //给cell赋值
    UIImageView *image = (id)[cell.contentView viewWithTag:1000];
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"头像";
            [image sd_setImageWithURL:[NSURL URLWithString:currUser.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"姓名";
            cell.detailTextLabel.text = currUser.real_name;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"帮帮号";
            if([currUser.user_name rangeOfString:@"@"].location != NSNotFound || [NSString isBlank:currUser.user_name])
                cell.detailTextLabel.text = @"未填写";
            else
                cell.detailTextLabel.text = currUser.user_name;
        }
    }
    else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"性别";
            NSString *sex = @"女";
            if(currUser.sex == 0) {
                sex = @"保密";
            } else if (currUser.sex== 1) {
                sex = @"男";
            }
            cell.detailTextLabel.text = sex;
        } else {
            cell.textLabel.text = @"个性签名";
            cell.detailTextLabel.text = [NSString isBlank:currUser.mood] ? @"未填写" : currUser.mood;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
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
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {//看当前设备是否能够拍照
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
        } else if (indexPath.row == 1) {
            ChangeUserName *vc = [ChangeUserName new];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == 2) {
            User *currUser = [UserManager manager].user;
            if([currUser.user_name rangeOfString:@"@"].location != NSNotFound || [NSString isBlank:currUser.user_name]) {
                ChangeUserBBH *vc = [ChangeUserBBH new];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else {
        User *_tempUser = [[UserManager manager].user deepCopy];
        if (indexPath.row == 0) {
            //选择性别
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cacleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *selectAction1 = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                _tempUser.sex = 1;
                [self changeUserInfo:_tempUser];
            }];
            UIAlertAction *selectAction2 = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                _tempUser.sex = 2;
                [self changeUserInfo:_tempUser];
            }];
            UIAlertAction *selectAction3 = [UIAlertAction actionWithTitle:@"保密" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               _tempUser.sex = 0;
                [self changeUserInfo:_tempUser];
            }];
            [alertVC addAction:cacleAction];
            [alertVC addAction:selectAction1];
            [alertVC addAction:selectAction2];
            [alertVC addAction:selectAction3];
            [self presentViewController:alertVC animated:YES completion:nil];
        } else {
            ChangeUserDetail *vc = [ChangeUserDetail new];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
#pragma mark --
#pragma mark -- PrivateMethod
- (void)changeUserInfo:(User *)user
{
    [UserHttp updateUserInfo:user handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        [[UserManager manager] updateUser:user];
        //更新用户员工
        for (Company *company in [_userManager getCompanyArr]) {
            Employee *employee = [[_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no] deepCopy];
            employee.real_name = user.real_name;
            employee.user_real_name = user.real_name;
            employee.user_name = user.user_name;
            employee.sex = user.sex;
            employee.mood = user.mood;
            [_userManager updateEmployee:employee];
        }
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    
    [UserHttp updateUserAvater:image userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        User *user = [_userManager.user deepCopy];
        user.avatar = data[@"data"][@"avatar"];
        [_userManager updateUser:user];
        
        //更新用户员工
        for (Company *company in [_userManager getCompanyArr]) {
            Employee *employee = [[_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no] deepCopy];
            employee.avatar = user.avatar;
            [_userManager updateEmployee:employee];
        }
        
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end