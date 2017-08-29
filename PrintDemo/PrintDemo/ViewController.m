//
//  ViewController.m
//  PrintDemo
//
//  Created by shenzhenshihua on 2017/8/23.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "ViewController.h"
#import "SocketTools.h"
#import "MMReceiptManager.h"
#import "MMPrinterManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *logtext;
@property (weak, nonatomic) IBOutlet UITextField *Ip;
@property (weak, nonatomic) IBOutlet UITextField *point;
@property(nonatomic,strong)SocketTools *socketTools;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [SocketTools shareSocketWithHost:@"192.168.1.103" port:9800];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnAction:(id)sender {
    [self.view endEditing:YES];

//    MMReceiptManager *manager = [[MMReceiptManager alloc] init];
//    manager.printerManager = [[MMPrinterManager alloc] init];
//    [manager basicSetting];
//    [manager writeData_title:@"肯德基" Scale:scale_2 Type:MiddleAlignment];
//    [manager writeData_items:@[@"收银员:001", @"交易时间:2016-03-17", @"交易号:201603170001"]];
//    [manager writeData_line];
//    [manager writeData_content:@[@{@"key01":@"名称", @"key02":@"单价", @"key03":@"数量", @"key04":@"总价"}]];
//    [manager writeData_line];
//    
//    NSData * data = manager.printerManager.sendData;
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"IntelliJIDEA_ReferenceCard" ofType:@"txt"];
//    NSData * data = [NSData dataWithContentsOfFile:path];
    NSString * str = @"hello word";
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    __weak typeof (self)ws = self;
    [_socketTools printData:data resBlock:^(NSString *res) {
        if (res.length) {
            [ws logwithTetx:res];
        }
    }];

    
}
- (IBAction)contentAction:(id)sender {
    [self.view endEditing:YES];

    if (!_Ip.text.length || !_point.text.length) {
        self.logtext.text = [NSString stringWithFormat:@"ip地址或者端口未填写\n%@",_logtext.text];
        return;
    }
    __weak typeof (self)ws = self;
  _socketTools = [SocketTools shareSocketWithHost:self.Ip.text port:self.point.text.integerValue resBlock:^(NSString *res) {
        if (res.length) {
            [ws logwithTetx:res];
        }
    }];

}


- (void)logwithTetx:(NSString *)text {
dispatch_async(dispatch_get_main_queue(), ^{
    self.logtext.text = [NSString stringWithFormat:@"%@\n%@",text,self.logtext.text];

});
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
