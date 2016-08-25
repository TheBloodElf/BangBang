//
//  VideoRecordController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "VideoRecordController.h"
#import "FileManager.h"

#define TIMER_INTERVAL 0.05
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface VideoRecordController ()<AVCaptureFileOutputRecordingDelegate> {
    NSMutableArray* urlArray;//保存视频片段的数组
    float currentTime; //当前视频长度
    NSTimer *countTimer; //计时器
    UIView* progressPreView; //进度条
    float progressStep; //进度条每次变长的最小单位
    UIButton* shootBt;//录制按钮
    UIButton* finishBt;//结束按钮
    UIButton* flashBt;//闪光灯
    UIButton* cameraBt;//切换摄像头
    FileManager *_fileManager;//文件管理器用于存放视频文件
}

@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@property (strong,nonatomic)  UIView *viewContainer;//视频容器
@property (strong,nonatomic)  UIImageView *focusCursor; //聚焦光标

@property float totalTime; //视频总长度 默认10秒

@end

@implementation VideoRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"视频录制";
    self.totalTime = self.totalTime ?: 100;
    urlArray = [@[] mutableCopy];
    progressStep = MAIN_SCREEN_WIDTH*TIMER_INTERVAL/_totalTime;
    _fileManager = [FileManager shareManager];
    //视频高度加进度条高度
    self.viewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 64, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 87 - 64)];
    [self.view addSubview:self.viewContainer];
    //聚焦光标
    self.focusCursor = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
    [self.focusCursor setImage:[UIImage imageNamed:@"focusImg"]];
    self.focusCursor.alpha = 0;
    [self.viewContainer addSubview:self.focusCursor];
    //下面的操作按钮
    UIView* btView = [[UIView alloc]initWithFrame:CGRectMake(0.5 * (MAIN_SCREEN_WIDTH - 86), MAIN_SCREEN_HEIGHT - 86, 86, 86)];
    btView.layer.cornerRadius = 43.f;
    btView.clipsToBounds = YES;
    btView.backgroundColor = [UIColor colorFromHexCode:@"0xeeeeee"];
    [self.view addSubview:btView];
    //录制/暂停按钮
    shootBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 76, 76)];
    shootBt.center = CGPointMake(43, 43);
    shootBt.backgroundColor = [UIColor colorFromHexCode:@"0xfa5f66"];
    [shootBt addTarget:self action:@selector(shootButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [shootBt setTitle:@"开始" forState:UIControlStateNormal];
    shootBt.layer.cornerRadius = 38;
    shootBt.clipsToBounds = YES;
    [btView addSubview:shootBt];
    //完成录制按钮
    finishBt = [UIButton buttonWithType:UIButtonTypeSystem];
    finishBt.frame = CGRectMake(MAIN_SCREEN_WIDTH - 60, MAIN_SCREEN_HEIGHT - 60, 60, 60);
    [finishBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    finishBt.backgroundColor = [UIColor whiteColor];
    [finishBt setTitle:@"完成" forState:UIControlStateNormal];
    [finishBt addTarget:self action:@selector(finishBtTap) forControlEvents:UIControlEventTouchUpInside];
    finishBt.hidden = YES;
    [self.view addSubview:finishBt];
    
    //初始化会话
    _captureSession=[[AVCaptureSession alloc]init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {//设置分辨率
        _captureSession.sessionPreset=AVCaptureSessionPreset640x480;
    }
    
    //获得输入设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    //初始化设备输出对象，用于获得输出数据
    _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addInput:audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    CALayer *layer= self.viewContainer.layer;
    layer.masksToBounds=YES;
    _captureVideoPreviewLayer.frame=  CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 87 - 10 - 64);
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    [self addGenstureRecognizer];
    //进度条
    progressPreView = [[UIView alloc]initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 87 - 10 - 64, 0, 4)];
    progressPreView.backgroundColor = [UIColor colorFromHexCode:@"0xffc738"];
    progressPreView.layer.cornerRadius = 2;
    progressPreView.clipsToBounds = YES;
    [self.viewContainer addSubview:progressPreView];
    //闪灯按钮
    flashBt = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH-90, 5, 34, 34)];
    [flashBt setBackgroundImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
    flashBt.layer.cornerRadius = 17;
    flashBt.clipsToBounds = YES;
    [flashBt addTarget:self action:@selector(flashBtTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewContainer addSubview:flashBt];
    //摄像头切换
    cameraBt = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH-40, 5, 34, 34)];
    [cameraBt setBackgroundImage:[UIImage imageNamed:@"changeCamer"] forState:UIControlStateNormal];
    cameraBt.layer.cornerRadius = 17;
    cameraBt.clipsToBounds = YES;
    [cameraBt addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewContainer addSubview:cameraBt];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
    //清除掉临时数据
    [_fileManager deleteExtionName:@"mov"];
    currentTime = 0;
    [progressPreView setFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 87 - 10 - 64, 0, 4)];
    shootBt.backgroundColor = [UIColor colorFromHexCode:@"0xfa5f66"];
    finishBt.hidden = YES;
}

-(void)flashBtTap:(UIButton*)bt{
    if (bt.selected == YES) {
        bt.selected = NO;
        //关闭闪光灯
        [flashBt setBackgroundImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
        [self setTorchMode:AVCaptureTorchModeOff];
    }else{
        bt.selected = YES;
        //开启闪光灯
        [flashBt setBackgroundImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
        [self setTorchMode:AVCaptureTorchModeOn];
    }
}
//开始定时器
-(void)startTimer{
    shootBt.backgroundColor =[UIColor colorFromHexCode:@"0xf8ad6a"];
    
    countTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [countTimer fire];
}
//停止定时器
-(void)stopTimer{
    shootBt.backgroundColor = [UIColor colorFromHexCode:@"0xfa5f66"];
    [countTimer invalidate];
    countTimer = nil;
}
- (void)onTimer:(NSTimer *)timer
{
    currentTime += TIMER_INTERVAL;
    float progressWidth = progressPreView.frame.size.width+progressStep;
    [progressPreView setFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 87 - 10 - 64, progressWidth, 4)];
    if (currentTime>2) {
        finishBt.hidden = NO;
    }
    //时间到了停止录制视频
    if (currentTime>=_totalTime) {
        [countTimer invalidate];
        countTimer = nil;
        [_captureMovieFileOutput stopRecording];
    }
}
-(void)finishBtTap {
    currentTime=_totalTime+10;
    [countTimer invalidate];
    countTimer = nil;
    //正在拍摄
    if (_captureMovieFileOutput.isRecording) {
        [_captureMovieFileOutput stopRecording];
    }else{//已经暂停了
        [self mergeAndExportVideosAtFileURLs:urlArray];
    }
}

#pragma mark 视频录制
- (void)shootButtonClick{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
        shootBt.backgroundColor = [UIColor colorFromHexCode:@"0xfa5f66"];
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
        [self.captureMovieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self getVideoSaveFilePathString]] recordingDelegate:self];
        [shootBt setTitle:@"暂停" forState:UIControlStateNormal];
        NSLog(@"开始录制...");
    }
    else {
        [self stopTimer];
        [self.captureMovieFileOutput stopRecording];//停止录制
        [shootBt setTitle:@"开始" forState:UIControlStateNormal];
        NSLog(@"暂停录制...");
    }
}
#pragma mark 切换前后摄像头
- (void)changeCamera:(UIButton*)bt {
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
        flashBt.hidden = NO;
    }else{
        flashBt.hidden = YES;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput=toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    
    //关闭闪光灯
    flashBt.selected = NO;
    [flashBt setBackgroundImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
    [self setTorchMode:AVCaptureTorchModeOff];
    
}

#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    [self startTimer];
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    [urlArray addObject:outputFileURL];
    //时间到了
    if (currentTime>=_totalTime) {
        [self mergeAndExportVideosAtFileURLs:urlArray];
    }
}
//合并输出文件 到一个文件  然后保存
- (void)mergeAndExportVideosAtFileURLs:(NSMutableArray *)fileURLArray
{
    NSError *error = nil;
    CGSize renderSize = CGSizeMake(0, 0);
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    CMTime totalDuration = kCMTimeZero;
    
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileURLArray) {
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        [assetArray addObject:asset];
        NSArray* tmpAry =[asset tracksWithMediaType:AVMediaTypeVideo];
        if (tmpAry.count>0) {
            AVAssetTrack *assetTrack = [tmpAry objectAtIndex:0];
            [assetTrackArray addObject:assetTrack];
            renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
            renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
        }
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        NSArray*dataSourceArray= [asset tracksWithMediaType:AVMediaTypeAudio];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:([dataSourceArray count]>0)?[dataSourceArray objectAtIndex:0]:nil
                             atTime:totalDuration
                              error:nil];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
        
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0+(MAIN_SCREEN_WIDTH / (MAIN_SCREEN_HEIGHT - 87 - 10 - 64))*( MAIN_SCREEN_HEIGHT - 87 - 10 - 64 - MAIN_SCREEN_WIDTH)/2));
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    NSString *path = [self getVideoMergeFilePathString];
    NSURL *mergeFileURL = [NSURL fileURLWithPath:path];
    
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 100);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW*(MAIN_SCREEN_WIDTH / (MAIN_SCREEN_HEIGHT - 87 - 10 - 64)));
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{}];
    [self.navigationController showSuccessTips:@"录制完成!"];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate && [self.delegate respondsToSelector:@selector(videoRecordFinish:)]) {
        [self.delegate videoRecordFinish:path];
    }
}
//最后合成为 mp4
- (NSString *)getVideoMergeFilePathString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [_fileManager fileStr:[NSString stringWithFormat:@"%@.mp4",nowTimeStr]];
    return fileName;
}

//录制保存的时候要保存为 mov
- (NSString *)getVideoSaveFilePathString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [_fileManager fileStr:[NSString stringWithFormat:@"%@.mov",nowTimeStr]];
    return fileName;
}
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

-(void)setTorchMode:(AVCaptureTorchMode )torchMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isTorchModeSupported:torchMode]) {
            [captureDevice setTorchMode:torchMode];
        }
    }];
}

-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}

-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.viewContainer addGestureRecognizer:tapGesture];
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.viewContainer];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
    }];
}

@end
