//
//  ViewController.m
//  MMPrinterDemo
//
//  Created by Zhaomike on 16/3/17.
//  Copyright © 2016年 mikezhao. All rights reserved.
//

#import "ViewController.h"
#import "MMReceiptManager.h"
#import "MMQRCode.h"

@interface ViewController ()

@property (strong, nonatomic) MMReceiptManager *manager;

@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)printReceipt:(id)sender {
    
    NSString *host = @"192.168.1.241";
    UInt16 port = 9100;
//    NSString *host = _ipTextField.text;
//    UInt16 port = (UInt16)[_portTextField.text integerValue];
    NSTimeInterval timeout = 10;
    MMReceiptManager *manager = [[MMReceiptManager alloc] initWithHost:host port:port timeout:timeout];
    [manager basicSetting];
    [manager writeData_title:@"肯德基" Scale:scale_2 Type:MiddleAlignment];
    [manager writeData_items:@[@"收银员:001", @"交易时间:2016-03-17", @"交易号:201603170001"]];
    [manager writeData_line];
    [manager writeData_content:@[@{@"key01":@"名称", @"key02":@"单价", @"key03":@"数量", @"key04":@"总价"}]];
    [manager writeData_line];
    [manager writeData_content:@[@{@"key01":@"汉堡", @"key02":@"10.00", @"key03":@"2", @"key04":@"20.00"}, @{@"key01":@"炸鸡", @"key02":@"8.00", @"key03":@"1", @"key04":@"8.00"}]];
    [manager writeData_line];
    [manager writeData_items:@[@"支付方式:现金", @"应收:28.00", @"实际:30.00", @"找零:2.00"]];
    UIImage *qrImage = [MMQRCode qrCodeWithString:@"www.google.cn" logoName:@"kfc.gif" size:400];
    [manager writeData_image:qrImage alignment:MiddleAlignment maxWidth:400];
    [manager openCashDrawer];
    [manager printReceipt];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



















