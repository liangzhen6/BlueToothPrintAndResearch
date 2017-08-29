//
//  BLEDetailViewController.m
//  HLBluetoothDemo
//
//  Created by Harvey on 16/4/29.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "BLEDetailViewController.h"
#import "ShoppingViewController.h"
#import "OrderWebController.h"

#import "SVProgressHUD.h"
#import "UIImage+Bitmap.h"
#import "HLPrinter.h"

@interface BLEDetailViewController ()<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)   NSMutableArray            *infos;  /**< 详情数组 */

@property (strong, nonatomic)   CBCharacteristic            *chatacter;  /**< 可写入数据的特性 */

@end

@implementation BLEDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"蓝牙详情";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"商品" style:UIBarButtonItemStylePlain target:self action:@selector(goToShopping)];
    
    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithTitle:@"网页" style:UIBarButtonItemStylePlain target:self action:@selector(goToOrder)];
    
    self.navigationItem.rightBarButtonItems = @[rightItem,rightItem2];
    
    _infos = [[NSMutableArray alloc] init];
    _tableView.rowHeight = 100;
    
    //连接蓝牙并展示详情
    [self loadBLEInfo];
}

- (void)goToOrder
{
    OrderWebController  *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderWebController"];
    orderVC.printBlock = ^(HLPrinter *printer) {
        NSData *mainData = [printer getFinalData];

        HLBLEManager *bleManager = [HLBLEManager sharedInstance];
        if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
            [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
                if (!error) {
                    NSLog(@"写入成功");
                }
            }];
        } else if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithoutResponse];
        }


    };
    [self.navigationController pushViewController:orderVC animated:YES];
}

- (void)goToShopping
{
    [self test];
//    return;
    
    
//    ShoppingViewController *shoppingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShoppingViewController"];
//    shoppingVC.printBlock = ^(HLPrinter *printInfo) {
//        
//        NSData *mainData = [printInfo getFinalData];
//        HLBLEManager *bleManager = [HLBLEManager sharedInstance];
//        if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
//            [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
//                if (!error) {
//                    NSLog(@"写入成功");
//                }
//            }];
//        } else if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
//            [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithoutResponse];
//        }
//    };
//    [self.navigationController pushViewController:shoppingVC animated:YES];
}

- (void)test{
    HLPrinter *printInfo = [[HLPrinter alloc] init];
    //[printInfo appendTitle:@"测试" value:@"1234"];
    //[printInfo appendTitle:@"车牌：苏D12345" value:@"车架号：LX56357354736474"];
    //[printInfo appendLeftText:@"贵重物品：无" middleText:@"旧件返还：否" rightText:@"洗车服务：无" isTitle:YES];
    [printInfo appendTitle:@"小保养" value:@"643243484.00"];
//    [printInfo addLittleTitle:@"  机油真不错呀" value:@"X1363740.12"];
//    [printInfo addLittleTitle:@"  机油真不错呀" value:@"X1363740.1"];
//    [printInfo addLittleTitle:@"  机油真不错呀" value:@"X1363740.123"];
//    [printInfo addLittleTitle:@"  机油真不错呀" value:@"X130.12"];
    [printInfo appendTitle:@"客户签名：" value:@"维修客户顾问：" valueOffset:230];
    //[printInfo appendTitle:@"  机油真不错呀" value:@"X10"];
//    [printInfo appendTitle:@"  机油" value:@"X10.1"];
//    NSString *string1 = @"机油防范大风大风";
//    NSString *string2 = @"  ";
//    NSString *string = [string2 stringByAppendingString:string1];
//    [printInfo appendTitle:string value:@"X60.13"];
//    [printInfo appendTitle:@"  机油防范分的十分舒服" value:@"X10.132"];
//    [printInfo appendTitle:@"  机油防范大风大风" value:@"X10.1343"];
//    [printInfo appendTitle:@"  机油防范大风大风" value:@"X10.13323"];
//    [printInfo appendTitle:@"  小保养" value:@"X0.143432"];
    //[printInfo appendText:@"总金额：62234444444338.00" alignment:HLTextAlignmentRight];
    
    NSData *mainData = [printInfo getFinalData];
    HLBLEManager *bleManager = [HLBLEManager sharedInstance];
    if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
        [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
            if (!error) {
                NSLog(@"写入成功");
            }
        }];
    } else if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithoutResponse];
    }

}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _infos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CBService *service = _infos[section];
    return service.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"infoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    CBService *service = _infos[indexPath.section];
    CBCharacteristic *character = [service.characteristics objectAtIndex:indexPath.row];
    CBCharacteristicProperties properties = character.properties;
    /**
     CBCharacteristicPropertyWrite和CBCharacteristicPropertyWriteWithoutResponse类型的特性都可以写入数据
     但是后者写入完成后，不会回调写入完成的代理方法{peripheral:didWriteValueForCharacteristic:error:},
     因此，你也不会受到block回调。
     所以首先考虑使用CBCharacteristicPropertyWrite的特性写入数据，如果没有这种特性，再考虑使用后者写入吧。
     */
    //
    if (properties & CBCharacteristicPropertyWrite) {
//        if (self.chatacter == nil) {
//            self.chatacter = character;
//        }
        self.chatacter = character;
    }
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",character.description];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

//- (void)getCharacter {
//    for (CBService * service in _infos) {
//        for (CBCharacteristic * character in service.characteristics) {
//            CBCharacteristicProperties properties = character.properties;
//            if (properties & CBCharacteristicPropertyWrite) {
//                self.chatacter = character;
//                return;
//            }
//        }
//    }
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"第%ld个服务",(section + 1)];
}

- (void)loadBLEInfo
{
    HLBLEManager *manager = [HLBLEManager sharedInstance];
    [manager connectPeripheral:_perpheral
                connectOptions:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}
        stopScanAfterConnected:YES
               servicesOptions:nil
        characteristicsOptions:nil
                 completeBlock:^(HLOptionStage stage, CBPeripheral *peripheral, CBService *service, CBCharacteristic *character, NSError *error) {
                     switch (stage) {
                         case HLOptionStageConnection:
                         {
                             if (error) {
                                 [SVProgressHUD showErrorWithStatus:@"连接失败"];
                                 
                             } else {
                                 [SVProgressHUD showSuccessWithStatus:@"连接成功"];
                                 
                             }
                             break;
                         }
                         case HLOptionStageSeekServices:
                         {
                             if (error) {
                                 [SVProgressHUD showSuccessWithStatus:@"查找服务失败"];
                             } else {
                                 [SVProgressHUD showSuccessWithStatus:@"查找服务成功"];
                                 [_infos addObjectsFromArray:peripheral.services];
                                 [_tableView reloadData];
                             }
                             break;
                         }
                         case HLOptionStageSeekCharacteristics:
                         {
                             // 该block会返回多次，每一个服务返回一次
                             if (error) {
                                 NSLog(@"查找特性失败");
                             } else {
                                 NSLog(@"查找特性成功");
                                 [_tableView reloadData];
                             }
                             break;
                         }
                         case HLOptionStageSeekdescriptors:
                         {
                             // 该block会返回多次，每一个特性返回一次
                             if (error) {
                                 NSLog(@"查找特性的描述失败");
                             } else {
//                                 NSLog(@"查找特性的描述成功");
                             }
                             break;
                         }
                         default:
                             break;
                     }
                     
                 }];
}


@end
