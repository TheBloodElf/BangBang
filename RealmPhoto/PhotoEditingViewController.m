//
//  PhotoEditingViewController.m
//  RealmPhoto
//
//  Created by lottak_mac2 on 16/8/17.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PhotoEditingViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "CLImageEditor.h"

@interface PhotoEditingViewController ()<PHContentEditingController,CLImageEditorDelegate>

@property (strong) PHContentEditingInput *input;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PhotoEditingViewController

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
    // Inspect the adjustmentData to determine whether your extension can work with past edits.
    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
    return NO;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    self.imageView.image = placeholderImage;
    self.input = contentEditingInput;
}
- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
    // Update UI to reflect that editing has finished and output is being rendered.
    
    // Render and provide output on a background queue.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //创建output并设置
        PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
        NSData *jpegData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
        PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:self.input.adjustmentData.formatIdentifier formatVersion:self.input.adjustmentData.formatVersion data:jpegData];
        output.adjustmentData = adjustmentData;
         //将转化后的图片存到renderedContentURL中
        [jpegData writeToURL:output.renderedContentURL options:NSDataWritingAtomic error:nil];
        completionHandler(output);
        // Clean up temporary files, etc.
    });
}

- (BOOL)shouldShowCancelConfirmation {
    
    return NO;
}

- (void)cancelContentEditing {
    
}
- (IBAction)editClicked:(id)sender {
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:self.imageView.image];
    editor.delegate = self;
    [self presentViewController:editor animated:YES completion:nil];
}
#pragma mark -- CLImageEditorDelegate
- (void)imageEditor:(CLImageEditor*)editor didFinishEdittingWithImage:(UIImage*)image {
    self.imageView.image = image;
    [editor dismissViewControllerAnimated:YES completion:nil];
}
- (void)imageEditorDidCancel:(CLImageEditor*)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}
@end
