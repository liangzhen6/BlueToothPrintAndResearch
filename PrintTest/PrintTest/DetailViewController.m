//
//  DetailViewController.m
//  PrintTest
//
//  Created by shenzhenshihua on 2017/8/23.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "DetailViewController.h"
#import <BabyBluetooth.h>

#import "MMReceiptManager.h"
#import "MMPrinterManager.h"

#define width [UIScreen mainScreen].bounds.size.width
#define height [UIScreen mainScreen].bounds.size.height
#define channelOnPeropheralView @"peripheralView"

@interface DetailViewController ()
{
    BabyBluetooth *baby;

}
@property(nonatomic,strong)NSMutableArray *services;
@property(nonatomic,strong)CBCharacteristic *characteristic;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];

    [self loadData];
    
    // Do any additional setup after loading the view.
}

-(void)loadData{
    baby.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    //    baby.connectToPeripheral(self.currPeripheral).begin();
}





//babyDelegate
-(void)babyDelegate{
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    __weak typeof(self)weakSelf = self;
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
    }];
    
    
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        if (!error) {
            NSLog(@"写入成功");
        }
        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置通知状态改变的block
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];

    
 
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            ///插入section到tableview
//            [weakSelf insertSectionToTableView:s];
        }
        
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
        [weakSelf insertRowToTableView:service];
        
    }];

    
    
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    
    
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
}


- (void)insertRowToTableView:(CBService *)service {
    NSLog(@"%@-caonima-%@",service.UUID,service.characteristics);
    [self.services addObject:service];
}


- (void)getACharacteristic {
    for (NSInteger i = 0; i < self.services.count; i++) {
        for (CBCharacteristic *s in [[self.services objectAtIndex:i] characteristics]) {
            CBCharacteristicProperties p = s.properties;
            if (p & CBCharacteristicPropertyWrite) {
                self.characteristic = s;
                return;
            }
//            NSLog(@"hello---%@",s);
//            if ([s.UUID.UUIDString isEqual:@"2AF1"]) {
//                self.characteristic = s;
//                return;
//            }
        }
    }

}
- (IBAction)btnAction:(id)sender {
    
    [self writeValue];

}


//写一个值
-(void)writeValue{
    //    int i = 1;
    
    [self getACharacteristic];
    
//    Byte b = 0X01;
//    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    
    if (!self.characteristic) {
        return;
    }
    MMReceiptManager *manager = [[MMReceiptManager alloc] init];
    manager.printerManager = [[MMPrinterManager alloc] init];
    [manager basicSetting];
    [manager writeData_title:@"肯德基" Scale:scale_2 Type:MiddleAlignment];
    [manager writeData_items:@[@"收银员:001", @"交易时间:2016-03-17", @"交易号:201603170001"]];
    [manager writeData_line];
    [manager writeData_content:@[@{@"key01":@"名称", @"key02":@"单价", @"key03":@"数量", @"key04":@"总价"}]];
    [manager writeData_line];
    
    NSData * data = manager.printerManager.sendData;
    
    [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}


- (NSMutableArray *)services {
    if (_services == nil) {
        _services = [NSMutableArray array];
    }
    return _services;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
