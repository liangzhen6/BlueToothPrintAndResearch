//
//  BluetoothCenter.h
//  BluetoothDemo
//
//  Created by shenzhenshihua on 2018/9/25.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BluetoothLockState) {
    lockBluetoothLockState = 0, ///< 关闭状态
    unLockBluetoothLockState,   ///< 开启状态
};
typedef NS_ENUM(NSUInteger, BluetoothLockLinkState) {
    offBluetoothLockLinkState = 0, ///< 处于断开状态
    onBluetoothLockLinkState,  ///< 处理链接状态
};

typedef void(^SendCommandBlock)(BluetoothLockState state);
typedef void(^ConnectBlock)(BluetoothLockLinkState state);

@interface BluetoothCenter : NSObject
@property(nonatomic,assign)BluetoothLockLinkState linkState;

/**
 单利创建方法

 @return 返回 单利BluetoothCenter
 */
+ (id)shareBluetoothCenter;

/**
 开始发出链接

 @param connectBlock 链接 的 结果
 */
- (void)bluetoothLockConnectCompletion:(ConnectBlock)connectBlock;

/**
 发出 开锁或者 关锁的命令

 @param lock 是 开锁（yes） 还是 关锁（no）
 @param commandBlock 发出命令后的 结果
 */
- (void)sendCommandState:(BOOL)lock completion:(SendCommandBlock)commandBlock;

@end
