//
//  WTQRCodeViewController.m
//  二维码扫描实现
//
//  Created by 王涛 on 2017/4/25.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import "WTQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface WTQRCodeViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureDevice             *_device;
    AVCaptureSession            *_session;
    AVCaptureDeviceInput        *_input;
    AVCaptureMetadataOutput     *_output;
    AVCaptureVideoPreviewLayer  *_previewLayer;
}

@property (strong, nonatomic)UIImage *image;
@property (strong, nonatomic)UIButton *titleButton;

@end

@implementation WTQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(choicePhoto)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.title = @"扫一扫";
    if (![self isCameraAvisible]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"相机不可用" preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *cencelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cencelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.backgroundColor = [UIColor blueColor];
    button.bounds = CGRectMake(0, 0, 100, 40);
    [button setTitle:@"点击扫描" forState:UIControlStateNormal];
    button.center = self.view.center;
    [button addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _titleButton = button;
    [self.view addSubview:_titleButton];
}

- (void)startSearch {

    _titleButton.alpha = 0;
    NSError *error;
    //设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //捕捉会话
    _session = [[AVCaptureSession alloc] init];
    //预先设置高质量的输入输出
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    //输入
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    // 输出
    _output = [[AVCaptureMetadataOutput alloc] init];
    //添加输入与输出设备
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    //设置代理并在主线程中刷新UI
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //    _output.rectOfInterest = CGRectMake(100, 100, 100, 100);
    //设置扫描范围 output.rectOfInterest
    //设置扫描二维码等
    [_output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];//预览
    _previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:_previewLayer atIndex:0];//添加预览图层
    [_session startRunning];
}
//判断相机是否可用
- (ErrorType)isCameraAvisible {

    BOOL flag;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        flag = YES;
        
    }else {
        flag = NO;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        flag = NO;
    }
    return flag;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    NSString *conten = @"";
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;

    conten = metadataObject.stringValue;
    if (conten.length > 1) {
        [self compelet:conten];
    }
    
}
//扫描成功时的提示音
- (void)playBeep{
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"6005"ofType:@"mp3"]], &soundID);
    AudioServicesPlaySystemSound(soundID);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)choicePhoto {
    //调用相册
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    self.image = [self alterImageSize:pickImage];
    _titleButton.titleLabel.text = @"正在扫描";
    [self dismissViewControllerAnimated:YES completion:^{
        [self codeRe];
    }];
}

//利用苹果原生的来扫描二维码图片，有时图片太大会造成crash 所以在这里修改一下图片大小
- (UIImage *)alterImageSize:(UIImage *)originalImage {

    UIGraphicsBeginImageContext(originalImage.size);
    [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    UIImage *NewImage = [UIImage imageWithCGImage:[UIGraphicsGetImageFromCurrentImageContext() CGImage]];
    return NewImage;
}

- (void)codeRe {
    
    NSString *content = @"" ;
    NSData *imageData = UIImagePNGRepresentation(self.image);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];
    _titleButton .titleLabel.text = @"扫描完成";
    //取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        content = result.messageString;
        [self compelet:content];
        return;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)compelet:(NSString *)resultMessageString {

    [self playBeep];
    [_session stopRunning];
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(searchReult:)]) {
        [self.delegate searchReult:resultMessageString];
    }
}

@end
