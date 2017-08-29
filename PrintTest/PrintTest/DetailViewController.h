//
//  DetailViewController.h
//  PrintTest
//
//  Created by shenzhenshihua on 2017/8/23.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DetailViewController : UIViewController

@property(strong,nonatomic)CBPeripheral *currPeripheral;

@end
