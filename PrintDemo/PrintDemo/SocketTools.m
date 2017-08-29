//
//  SocketTools.m
//  PrintDemo
//
//  Created by shenzhenshihua on 2017/8/23.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "SocketTools.h"
#import <GCDAsyncSocket.h>
@interface SocketTools ()<GCDAsyncSocketDelegate>
@property(nonatomic,strong)GCDAsyncSocket *asyncSocket;
//@property(nonatomic,strong)GCDAsyncSocket *serverSocket;
@property(nonatomic,copy)NSString * host;
@property(nonatomic)uint16_t port;
@end
@implementation SocketTools
static SocketTools * socketTools = nil;
+ (id)shareSocket {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketTools = [[SocketTools alloc] init];
    });
    return socketTools;
}

+ (id)shareSocketWithHost:(NSString *)host port:(uint16_t)port resBlock:(ContentBlock)contentBlock {
    SocketTools * socket = [SocketTools shareSocket];
    socket.contentBlock = contentBlock;
    socket.host = host;
    socket.port = port;
    NSError *error = nil;
    [socket.asyncSocket connectToHost:host onPort:port error:&error];
//    [socket.serverSocket acceptOnPort:port error:nil];
    if (error) {
        NSLog(@"%@",error);
    }
    return socket;
}

- (id)init {
    self = [super init];
    if (self) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//        _serverSocket =  [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}
- (void)printData:(NSData *)data resBlock:(SendBlock)sendBlock {
    self.sendBlock = sendBlock;
    [_asyncSocket writeData:data withTimeout:-1 tag:9855555];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSString * res = [NSString stringWithFormat:@"已经连接到host=%@=========port=%d",host,port];
    NSLog(@"%@", res);
    if ([host isEqualToString:_host]) {
        if (self.contentBlock) {
            self.contentBlock(res);
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@----已经接收消息---%@",sock,json);
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == 9855555) {
        if (self.sendBlock) {
            self.sendBlock(@"--已经发送消息-");
        }
    }
       NSLog(@"%@----已经发送消息---%@",sock,_asyncSocket);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"断开连接失败");
    if (self.contentBlock) {
        self.contentBlock(@"断开连接失败");
    }

}





@end
