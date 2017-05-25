//
//  WTQRCodeViewController.h
//  二维码扫描实现
//
//  Created by 王涛 on 2017/4/25.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ErrorType){
    NoCameraAuthStatus = 0,
    CameraUnAvilable,
    Aviliable
};

@protocol WTQRCodeViewDelegate <NSObject>

- (void)searchReult:(NSString *)string;
- (void)systemError:(ErrorType)error;

@end

@interface WTQRCodeViewController : UIViewController

@property (nonatomic, assign) id<WTQRCodeViewDelegate>   delegate;

@end
