//
//  AudioRecordController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AudioRecordController.h"
#import "FileManager.h"

@interface AudioRecordController () {
    FileManager *_fileManager;
    AVAudioRecorder *_aVAudioRecorder;
    NSString *_fileUrl;
}
@property (weak, nonatomic) IBOutlet UIImageView *audioImageView;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

@end

@implementation AudioRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"音频录制";
    _fileManager = [FileManager shareManager];
    _fileUrl = [_fileManager fileStr:[NSString stringWithFormat:@"%@.aac",@([NSDate date].timeIntervalSince1970)]];
    NSDictionary *settingDic = [[NSDictionary alloc] initWithObjectsAndKeys:@(kAudioFormatMPEG4AAC),AVFormatIDKey,@(1000.0),AVSampleRateKey,@(2),AVNumberOfChannelsKey,@(8),AVLinearPCMBitDepthKey,@(NO),AVLinearPCMIsBigEndianKey,@(NO),AVLinearPCMIsFloatKey,nil];
    NSError *error = nil;
    _aVAudioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_fileUrl] settings:settingDic error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return;
    }
    [_aVAudioRecorder prepareToRecord];
    
    NSMutableArray *imageArr = [@[] mutableCopy];
    for (int i = 1;i <= 20;i ++) {
        NSString *imageName = [NSString stringWithFormat:@"VoiceSearchFeedback%03d",i];
        [imageArr addObject:[UIImage imageNamed:imageName]];
    }
    self.audioImageView.animationImages = imageArr;
    [self.recordBtn addTarget:self action:@selector(beginAudio:) forControlEvents:UIControlEventTouchDown];
    [self.recordBtn addTarget:self action:@selector(endAudio:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
}
//开始录制
- (void)beginAudio:(id)sender {
    [self.audioImageView startAnimating];
    [self.recordBtn setTitle:@"松开录音完毕" forState:UIControlStateNormal];
    [_aVAudioRecorder record];
}
//结束录制
- (void)endAudio:(id)sender {
    [self.audioImageView stopAnimating];
    [self.navigationController showSuccessTips:@"录制成功"];
    [_aVAudioRecorder stop];
    if(self.delegate && [self.delegate respondsToSelector:@selector(audioRecordFinish:)]) {
        [self.delegate audioRecordFinish:_fileUrl];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
