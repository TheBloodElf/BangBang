//
//  WebNonstandarViewController.m
//  BangBang
//
//  Created by Xiaoyafei on 15/9/29.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "WebNonstandarViewController.h"
#import <QuickLook/QuickLook.h>
#import <AFNetworking/AFNetworking.h>
#import "RYChatController.h"
#import "SingleSelectController.h"
#import "MuliteSelectController.h"
#import "SelectDateController.h"
#import "SelectImageController.h"
#import "MoreSelectView.h"
#import "PlainPhotoBrose.h"
#import "UserManager.h"
#import "IdentityManager.h"
#import "UserHttp.h"
#import "RCTransferSelectViewController.h"
#import "CreateMeetingController.h"
#import "MeetingSiginReaderController.h"
#import "FileManager.h"

@interface WebNonstandarViewController ()<UIWebViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,QLPreviewControllerDataSource,SingleSelectDelegate,MuliteSelectDelegate,MoreSelectViewDelegate,SelectImageDelegate,MeetingSiginReaderDelegate,UIDocumentInteractionControllerDelegate>{
    NSURL *filePath1;
    NSString *title;
    NSString *detail;
    NSString *app_guid;
    //为了做到同步 我也是蛮拼的 最笨的方法
    __block int uploadPhotoNumber;
    NSArray *uploadPhotos;
}
@property (nonatomic,strong) WebViewJavascriptBridge *bridge;//交互中间件
@end

@implementation WebNonstandarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    uploadPhotos = @[];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIWebView *wb = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    wb.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:wb];
    wb.scrollView.bounces = NO;
    if (self.showNavigationBar == YES) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage colorImg:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage colorImg:[UIColor clearColor]]];
        [self.navigationController.navigationBar setShadowImage:[UIImage colorImg:[UIColor clearColor]]];
    }
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:wb webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    //返回上一页
    [_bridge registerHandler:@"preViewControllerObjc" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.navigationController popViewControllerAnimated:YES];
        responseCallback(@"Response from testObjcCallback");
    }];
    //拨号
    [_bridge registerHandler:@"callUserPhoneObjc" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",data[@"userPhone"]]]];
        responseCallback(@"Response from testObjcCallback");
    }];
    //创建会议
    [_bridge registerHandler:@"addMeetingObjc" handler:^(id data, WVJBResponseCallback responseCallback){
        responseCallback(@"Response from testObjcCallback");
        CreateMeetingController *createMeeting = [CreateMeetingController new];
        createMeeting.createFinish = ^() {
            //调用JS刷新会议列表
            [_bridge callHandler:@"onSaveCallback" data:@"" responseCallback:^(id response) {
                NSLog(@"xyf-----------: %@", response);
            }];
        };
        [self.navigationController pushViewController:createMeeting animated:YES];
    }];
    //开始单聊
    [_bridge registerHandler:@"startPrivateChat" handler:^(id data, WVJBResponseCallback responseCallback){
        NSString *userNo = [data objectForKey:@"userno"];
        NSString *userName = [data objectForKey:@"realname"];
        //单聊
        RYChatController *conversationVC = [[RYChatController alloc]init];
        conversationVC.conversationType =ConversationType_PRIVATE; //会话类型，这里设置为 PRIVATE 即发起单聊会话。
        conversationVC.targetId = userNo; // 接收者的 targetId，这里为举例。
        conversationVC.title = userName; // 会话的 title。
        [self.navigationController pushViewController:conversationVC animated:YES];
    }];
    
    //会议签到
    [_bridge registerHandler:@"signinMeetingObjc" handler:^(id data, WVJBResponseCallback responseCallback){
        MeetingSiginReaderController *sigin = [MeetingSiginReaderController new];
        sigin.delegate = self;
        [self.navigationController pushViewController:sigin animated:YES];
        responseCallback(@"Response from testObjcCallback");
    }];
    
    //选择时间
    [_bridge registerHandler:@"selectTimeObjc" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary* result = (NSDictionary*)data;
        NSNumber* number = [result valueForKey:@"isDateTime"];
        SelectDateController * select = [SelectDateController new];
        select.datePickerMode = [number isEqual:@0] ? UIDatePickerModeDateAndTime : UIDatePickerModeDate;
        select.selectDateBlock = ^(NSDate *date) {
            //发送选取的数据到JS
            __block  NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
            [_bridge callHandler:@"endSelectTimeIOS" data:timeSp responseCallback:^(id responseData){
                NSLog(@"xyf-----------: %@", responseData);
                NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeSp.longLongValue];
                NSLog(@"time  = %@",confromTimesp);
            }];
        };
        select.providesPresentationContextTransitionStyle = YES;
        select.definesPresentationContext = YES;
        select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:select animated:NO completion:nil];
    }];
    
    //选择联系人
    [_bridge registerHandler:@"selectConnectPersonObjc" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary* result = (NSDictionary*)data;
        NSNumber* number = [result valueForKey:@"isMultiple"];
        //已选择的
        NSMutableArray<Employee*> *selectedDataArr= [@[] mutableCopy];
        for (NSString *str in [result valueForKey:@"selectedDataArr"]) {
            Employee *emp = [Employee new];
            emp.employee_guid = str;
            [selectedDataArr addObject:emp];
        }
        //排除显示的
        NSMutableArray<Employee*> *outEmployees= [@[] mutableCopy];
        for (NSString *str in [result valueForKey:@"outEmployees"]) {
            Employee *emp = [Employee new];
            emp.employee_guid = str;
            [outEmployees addObject:emp];
        }
        if([number isEqual:@0]){ //单选
            SingleSelectController *choseJoinController = [[SingleSelectController alloc]init];
            choseJoinController.outEmployees = outEmployees;
            choseJoinController.delegate = self;
            [self.navigationController pushViewController:choseJoinController animated:YES];
        }else{ //多选
            MuliteSelectController *choseJoinController = [[MuliteSelectController alloc]init];
            choseJoinController.selectedEmployees = selectedDataArr;
            choseJoinController.outEmployees = outEmployees;
            choseJoinController.delegate = self;
            [self.navigationController pushViewController:choseJoinController animated:YES];
        }
    }];
    
    //选取图片
    [_bridge registerHandler:@"pickerFileObjc" handler:^(id data, WVJBResponseCallback responseCallback){
        app_guid = [data objectForKey:@"appGuid"];
        BOOL isMulti = [[data objectForKey:@"isMulti"] boolValue];
        NSInteger chooseNum = [[data objectForKey:@"chooseNum"] integerValue] ?: 9;
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *select = [UIAlertAction actionWithTitle:@"选取相册图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(isMulti == NO) {
                UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                [self presentViewController:picker animated:YES completion:nil];
            } else {
                SelectImageController *selectImage = [SelectImageController new];
                selectImage.maxSelect = (int)chooseNum;
                selectImage.delegate = self;
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:selectImage] animated:YES completion:nil];
            }
        }];
        UIAlertAction *creame = [UIAlertAction actionWithTitle:@"现在拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
        [alertVC addAction:cancle];
        [alertVC addAction:select];
        [alertVC addAction:creame];
        [self presentViewController:alertVC animated:YES completion:nil];
    }];
    //动态中打开新的网页url
    [_bridge registerHandler:@"urlBrowserObj" handler:^(id data, WVJBResponseCallback responseCallback){
        NSString *urlOpen = [data objectForKey:@"urlOpen"];
        if([urlOpen rangeOfString:@"?"].location != NSNotFound) {
            urlOpen = [NSString stringWithFormat:@"%@&access_token=%@&company_no=%ld&user_guid=%@",urlOpen,[IdentityManager manager].identity.accessToken,[UserManager manager].user.currCompany.company_no,[UserManager manager].user.user_guid];
        } else {
            urlOpen = [NSString stringWithFormat:@"?%@access_token=%@&company_no=%ld&user_guid=%@",urlOpen,[IdentityManager manager].identity.accessToken,[UserManager manager].user.currCompany.company_no,[UserManager manager].user.user_guid];
        }
        WebNonstandarViewController *vc = [WebNonstandarViewController new];
        vc.applicationUrl = [urlOpen stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        vc.showNavigationBar = NO;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    //图片预览
    [_bridge registerHandler:@"imageBrowserObj" handler:^(id data, WVJBResponseCallback responseCallback){
        
        NSMutableArray *photos = [NSMutableArray array];
        NSArray *imageUrls = [[data objectForKey:@"urls"] componentsSeparatedByString:@";"];
        for (int index = 0; index < imageUrls.count; index ++) {
            Photo *photo = [Photo new];
            photo.oiginalUrl = [NSURL URLWithString:imageUrls[index]];
            [photos addObject:photo];
        }
        NSInteger index = [[data objectForKey:@"index"] integerValue];
        PlainPhotoBrose *rose = [PlainPhotoBrose new];
        rose.index = (int)index;
        rose.photoArr = photos;
        [self.navigationController pushViewController:rose animated:YES];
    }];
    //文件下载或预览
    [_bridge registerHandler:@"fileDownloadObj" handler:^(id data,WVJBResponseCallback responseCallback){
        NSString *url = [data objectForKey:@"url"];
        NSString *name = [data objectForKey:@"name"];
        if([[FileManager shareManager] fileIsExit:name]) {
            UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[[FileManager shareManager] fileStr:name]]];
            documentController.delegate = self;
            [documentController presentPreviewAnimated:YES];
        } else {
            [self.navigationController.view showLoadingTips:@""];
            [[FileManager shareManager] downFile:url handler:^(id data, MError *error) {
                [self.navigationController.view dismissTips];
                if(error) {
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                [self.navigationController.view showSuccessTips:@"文件下载成功"];
            }];
        }
    }];
    NSURL *nsurl =[NSURL URLWithString:_applicationUrl];
    NSURLRequest *request =[NSURLRequest requestWithURL:nsurl];
    [wb loadRequest:request];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:!self.showNavigationBar animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
#pragma mark -- UIDocumentInteractionControllerDelegate
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *) controller {
    return self;
}
#pragma mark -- MeetingSiginReaderDelegate
- (void)reader:(MeetingSiginReaderController *)reader didScanResult:(NSString *)result {
    //调用JS刷新会议列表
    [_bridge callHandler:@"getScanningUrl" data:result responseCallback:^(id response) {
        NSLog(@"xyf-----------: %@", response);
    }];
    //等一会儿退出当前页面
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
//单选回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    uploadPhotoNumber = 0;
    uploadPhotos = @[img];
    [self.navigationController.view showLoadingTips:@"上传附件..."];
    [self sendImageArr];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- SelectImageDelegate
- (void)selectImageFinish:(NSMutableArray<Photo *> *)photoArr {
    NSMutableArray *array = [@[] mutableCopy];
    for (Photo *hpoto in photoArr) {
        [array addObject:hpoto.oiginalImage];
    }
    uploadPhotoNumber = (int)array.count - 1;
    uploadPhotos = array;
    [self.navigationController.view showLoadingTips:@"上传附件..."];
    [self sendImageArr];
}
#pragma mark - SingleSelectDelegate
- (void)singleSelect:(Employee*)employee {
    //取出数据
    NSString* employeeGuid = employee.employee_guid;
    NSString* employeeAvatar = employee.avatar;
    NSString* employeeName = employee.user_real_name;
    NSDictionary* onePerson = @{@"employeeGuid":employeeGuid,
                                @"employeeAvatar":employeeAvatar,
                                @"employeeName":employeeName
                                };
    NSArray* onePersonArr = [[NSArray alloc]initWithObjects:onePerson, nil];
    //发送选取的数据到JS
    [_bridge callHandler:@"endSelectConnectPersonIOS" data:onePersonArr responseCallback:^(id responseData){
        NSLog(@"xyf-----------: %@", responseData);
    }];
}
#pragma mark -- MuliteSelectDelegate
- (void)muliteSelect:(NSMutableArray<Employee*>*)employeeArr {
    NSMutableArray* sendUsersArray = [NSMutableArray new]; //保存若干字典的数组
    for(int i = 0; i < employeeArr.count; i++){
        Employee* employee = [employeeArr objectAtIndex:i];
        //取数据
        NSString* employeeGuid = employee.employee_guid;
        NSString* employeeAvatar = employee.avatar;
        NSString* employeeName = employee.user_real_name;
        NSDictionary* onePerson = @{@"employee_guid":employeeGuid,
                                    @"avatar":employeeAvatar,
                                    @"user_real_name":employeeName
                                    };
        [sendUsersArray addObject:onePerson];
    }
    //发送选取的数据到JS
    [_bridge callHandler:@"endSelectConnectPersonIOS" data:sendUsersArray responseCallback:^(id responseData){
        NSLog(@"xyf-----------: %@", responseData);
    }];
}
#pragma mark --- UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.navigationController.view showLoadingTips:@""];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.navigationController.view dismissTips];
    title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    detail = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
    detail = [detail stringByReplacingOccurrencesOfString:@" " withString:@""];
    detail = [detail stringByReplacingOccurrencesOfString:title withString:@""];
    detail = [detail stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    self.navigationItem.title = title;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.navigationController.view dismissTips];
    [self.navigationController.view showFailureTips:@"网络出错了"];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [request.URL absoluteString];
    _applicationUrl = url;
    if ([url rangeOfString:@"bb_nav_is_share=true"].location != NSNotFound) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(rightClicked:)];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    return YES;
}
- (void)rightClicked:(UIBarButtonItem*)item {
    //弹出分享视图
    RCRichContentMessage *richContentMessage = [RCRichContentMessage messageWithTitle:title digest:detail imageURL:@"http://img2.anzhi.com/data3/icon/201510/02/com.lottak.bangbang_26403600_72.png" url:_applicationUrl extra:nil];
    RCTransferSelectViewController *selectVC = [[RCTransferSelectViewController alloc] init];
    selectVC.data = richContentMessage;
    [self.navigationController pushViewController:selectVC animated:YES];
}
//多张图片上传函数
- (void)sendImageArr {
    if(uploadPhotoNumber < 0) {
        [self.navigationController.view dismissTips];
        [self.navigationController.view showSuccessTips:@"图片上传成功"];
        return;
    }
    [UserHttp updateImageGuid:app_guid image:uploadPhotos[uploadPhotoNumber] handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
        } else {
            uploadPhotoNumber = uploadPhotoNumber - 1;
            [_bridge callHandler:@"selectedFilesIOS" data:data[@"data"] responseCallback:^(id responseData){
                NSLog(@"xyf-----------: %@", responseData);
            }];
            [self sendImageArr];
        }
    }];
}
#pragma mark - PreViewDelegate
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return filePath1;
}
@end
