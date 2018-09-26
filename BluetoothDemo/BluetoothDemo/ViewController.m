//
//  ViewController.m
//  BluetoothDemo
//
//  Created by shenzhenshihua on 2018/9/25.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothCenter.h"
@interface ViewController ()

@end
/* 驱动蓝牙继电器 开关指令为 hex(16进制) 开<ff> 关<00> */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[BluetoothCenter shareBluetoothCenter] bluetoothLockConnectCompletion:^(BluetoothLockLinkState state) {
        NSLog(@"%lu",(unsigned long)state);
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[BluetoothCenter shareBluetoothCenter] sendCommandState:YES completion:nil];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[BluetoothCenter shareBluetoothCenter] sendCommandState:NO completion:nil];
        });
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
