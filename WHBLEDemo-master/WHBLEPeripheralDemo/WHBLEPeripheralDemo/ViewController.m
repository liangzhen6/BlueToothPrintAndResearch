//
//  ViewController.m
//  WHBLEPeripheralDemo
//  https://github.com/remember17/WHBLEDemo
//  Created by 吴浩 on 2017/7/18.
//  Copyright © 2017年 wuhao. All rights reserved.
//  http://www.jianshu.com/p/38a4c6451d93

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

@interface ViewController () <CBPeripheralManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property(nonatomic,strong)NSMutableData * mutData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"蓝牙外设";
    // 创建外设管理器，会回调peripheralManagerDidUpdateState方法
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

/** 设备的蓝牙状态
    CBManagerStateUnknown = 0,  未知
    CBManagerStateResetting,    重置中
    CBManagerStateUnsupported,  不支持
    CBManagerStateUnauthorized, 未验证
    CBManagerStatePoweredOff,   未启动
    CBManagerStatePoweredOn,    可用
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBManagerStatePoweredOn) {
        // 创建Service（服务）和Characteristics（特征）
        [self setupServiceAndCharacteristics];
        // 根据服务的UUID开始广播
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/** 创建服务和特征 */
- (void)setupServiceAndCharacteristics {
    // 创建服务
    CBUUID *serviceID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceID primary:YES];
    // 创建服务中的特征
    CBUUID *characteristicID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    CBMutableCharacteristic *characteristic = [
                                               [CBMutableCharacteristic alloc]
                                               initWithType:characteristicID
                                               properties:
                                               CBCharacteristicPropertyRead |
                                               CBCharacteristicPropertyWrite |
                                               CBCharacteristicPropertyNotify
                                               value:nil
                                               permissions:CBAttributePermissionsReadable |
                                               CBAttributePermissionsWriteable
                                               ];
    // 特征添加进服务
    service.characteristics = @[characteristic];
    // 服务加入管理
    [self.peripheralManager addService:service];
    
    // 为了手动给中心设备发送数据
    self.characteristic = characteristic;
}

/** 中心设备读取数据的时候回调 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    // 请求中的数据，这里把文本框中的数据发给中心设备
    request.value = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    // 成功响应请求
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

/** 中心设备写入数据的时候回调 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    // 写入数据的请求
    CBATTRequest *request = requests.lastObject;
    // 把写入的数据显示在文本框中
//    self.textField.text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
    NSData * data = request.value;
//    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    [self.textField setText:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];

//    [self.mutData appendData:[dict objectForKey:@"data"]];
//    if (data.length == 3) {
//        NSLog(@"完成写入");
//        self.imageView.image = [UIImage imageWithData:self.mutData];
//    }else{
//        [self.mutData appendData:data];
//        NSLog(@"继续写入");
//    }
//    if ([[dict objectForKey:@"flags"] isEqualToString:@"none"]) {
//        self.imageView.image = [UIImage imageWithData:self.mutData];
//    }
    
}

/** 订阅成功回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

/** 取消订阅回调 */
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

/** 通过固定的特征发送数据到中心设备 */
- (IBAction)didClickPost:(id)sender {
    BOOL sendSuccess = [self.peripheralManager updateValue:[self.textField.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristic onSubscribedCentrals:nil];
//    NSData * data = UIImageJPEGRepresentation(self.imageView.image, 1);
//        BOOL sendSuccess = [self.peripheralManager updateValue:data forCharacteristic:self.characteristic onSubscribedCentrals:nil];
    if (sendSuccess) {
        NSLog(@"数据发送成功");
    }else {
        NSLog(@"数据发送失败");
    }
}


- (NSMutableData *)mutData {
    if (_mutData == nil) {
        _mutData = [[NSMutableData alloc] init];
    }
    return _mutData;
}

@end

