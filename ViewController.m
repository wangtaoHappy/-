//
//  ViewController.m
//  二维码扫描实现
//
//  Created by 王涛 on 2017/4/25.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import "ViewController.h"
#import "WTQRCodeViewController.h"
@interface ViewController ()<WTQRCodeViewDelegate>
{
    UILabel *_lable;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.center = self.view.center;
    button.backgroundColor = [UIColor redColor];
    button.bounds = CGRectMake(0, 0, 100, 50);
    [button setTitle:@"开始扫描" forState:UIControlStateNormal];
    [button setTintColor:[UIColor grayColor]];
    [button addTarget:self action:@selector(starSearsh:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _lable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetWidth(self.view.bounds)/2, button.frame.origin.y + button.frame.size.height, CGRectGetWidth(self.view.bounds), 40)];
    _lable.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_lable];
}

- (void)starSearsh:(UIButton *)sender {

    WTQRCodeViewController *VC = [[WTQRCodeViewController alloc] init];
    VC.delegate = self;
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)searchReult:(NSString *)string {

    _lable.text = string;
    NSLog(@"%@",string);
}

- (void)systemError:(ErrorType)error {

    NSLog(@"%ld",(long)error);
}
@end
