//
//  BluetoothCenter.m
//  BluetoothDemo
//
//  Created by shenzhenshihua on 2018/9/25.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "BluetoothCenter.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothCenter ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property(nonatomic,assign)BluetoothLockState lockState;
@property(nonatomic,copy)SendCommandBlock commandBlock;
@property(nonatomic,copy)ConnectBlock connectBlock;
@end
static BluetoothCenter * _bluetoothCenter;
static NSString * const commandOn = @"ff";  ///< 开启
static NSString * const commandOff = @"00"; ///< 关闭

@implementation BluetoothCenter
+ (id)shareBluetoothCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_bluetoothCenter == nil) {
            _bluetoothCenter = [[BluetoothCenter alloc] init];
        }
    });
    return _bluetoothCenter;
}
- (void)bluetoothLockConnectCompletion:(ConnectBlock)connectBlock {
    self.connectBlock = connectBlock;
    // 初始化蓝牙 并且链接
    [self initBluetoothCenter];
}
/**
 初始化蓝牙
 */
- (void)initBluetoothCenter {
    dispatch_queue_t globleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:globleQueue];
}

#pragma mark --CBCentralManagerDelegate
/** 判断手机蓝牙状态
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            {// 可用
                NSLog(@"可用");
                //开始扫描设备
                [central scanForPeripheralsWithServices:nil options:nil];
            }
            break;
        case CBManagerStatePoweredOff:
            {// 关闭可用
            
            }
            break;
        case CBManagerStateUnsupported:
            {// 不支持
            
            }
            break;
        case CBManagerStateUnauthorized:
            {// 没有授权
            
            }
            break;
        default:
            break;
    }
}
/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 只连接 BK_91FFDDCC 这个的蓝牙
    if ([advertisementData[@"kCBAdvDataLocalName"] isEqualToString:@"BK_91FFDDCC"]) {
        self.peripheral = peripheral;
        // 连接 设备
        [central connectPeripheral:peripheral options:nil];
    }
    NSLog(@"%@-----%@---%@", peripheral.identifier, advertisementData, RSSI);
}
/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 停止扫描
    [self.centralManager stopScan];
    // 设置链接状态
    self.linkState = onBluetoothLockLinkState;
    if (self.connectBlock) {
        self.connectBlock(self.linkState);
    }
    // 设置 外设 代理
    peripheral.delegate = self;
    // 寻找服务 (三个方法  分别是: uuid  特征值 和uuid+服务) nil 搜寻所有的
    [peripheral discoverServices:nil];
}
/** 连接失败的回调 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // 设置链接状态
    self.linkState = offBluetoothLockLinkState;
    if (self.connectBlock) {
        self.connectBlock(self.linkState);
    }
    NSLog(@"连接失败的原因：%@", error);
}
/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"断开连接的原因：%@", error);
    // 设置链接状态
    self.linkState = offBluetoothLockLinkState;
    if (self.connectBlock) {
        self.connectBlock(self.linkState);
    }
    // 断开连接可以重新连接
    [central connectPeripheral:peripheral options:nil];
}
#pragma mark --CBCentralManagerDelegate--end

#pragma mark --CBPeripheralDelegate
/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        // 只有 uuid 为 FEE0 才是正确的服务
        if ([service.UUID.UUIDString isEqualToString:@"FEE0"]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
    }
    
    // 这里只获取一个特征，写入数据的时候需要用到这个特征
    self.characteristic = service.characteristics.firstObject;
    NSLog(@"%@",self.characteristic.description);
    /*
     直接读取这个特征数据，会调用didUpdateValueForCharacteristic
    [peripheral readValueForCharacteristic:self.characteristic];
     订阅通知
    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
     */
}
/** 订阅状态的改变 */
/* 当前的设备不支持 订阅
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
    } else {
        NSLog(@"取消订阅");
    }
}*/
/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 拿到外设发送过来的数据
    NSLog(@"拿到外设发送过来的数据");
        NSData *data = characteristic.value;
    //    self.textField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"666%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}
/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"写入成功:%@---%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding],error);
    if (self.commandBlock) {
        self.commandBlock(self.lockState);
    }
}
#pragma mark --CBPeripheralDelegate --end

#pragma mark --send command
// 写入命令
- (void)sendCommandState:(BOOL)lock completion:(SendCommandBlock)commandBlock {
    self.commandBlock = commandBlock;
    NSString * commandStr = nil;
    if (lock) {
        commandStr = commandOn;
        _lockState = unLockBluetoothLockState;
    } else {
        commandStr = commandOff;
        _lockState = lockBluetoothLockState;
    }
    // 将指令转换为 16 进制的方式
    NSData *data = [self convertHexStrToData:commandStr];
    
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}
/* 将字符串转化为Hex(16进制) NSData */
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] init];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}


    
@end
