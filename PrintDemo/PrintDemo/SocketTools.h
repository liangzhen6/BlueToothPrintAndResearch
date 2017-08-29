//
//  SocketTools.h
//  PrintDemo
//
//  Created by shenzhenshihua on 2017/8/23.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ContentBlock)(NSString *res);
typedef void(^SendBlock)(NSString *res);

@interface SocketTools : NSObject

@property(nonatomic,copy)ContentBlock contentBlock;
@property(nonatomic,copy)SendBlock sendBlock;

+ (id)shareSocket;

+ (id)shareSocketWithHost:(NSString *)host port:(uint16_t)port resBlock:(ContentBlock)contentBlock;

- (void)printData:(NSData *)data resBlock:(SendBlock)sendBlock;

@end
