//
//  ShoppingViewController.m
//  BlueToochDemo
//
//  Created by Harvey on 16/4/26.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "ShoppingViewController.h"

@interface ShoppingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)   NSArray            *goodsArray;  /**< 商品数组 */

@end

@implementation ShoppingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"购物车";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"打印" style:UIBarButtonItemStylePlain target:self action:@selector(printAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSDictionary *dict1 = @{@"name":@"铅笔",@"amount":@"5",@"price":@"2.0"};
    NSDictionary *dict2 = @{@"name":@"橡皮",@"amount":@"1",@"price":@"1.0"};
    NSDictionary *dict3 = @{@"name":@"笔记本",@"amount":@"3",@"price":@"3.0"};
    self.goodsArray = @[dict1, dict2, dict3];
}

- (HLPrinter *)getPrinter
{
    
    HLPrinter *printer = [[HLPrinter alloc] init];
    
    // 图片
    [printer appendImage:[UIImage imageNamed:@"dayin-jieche.jpg"] alignment:HLTextAlignmentCenter maxWidth:450];
    
//    NSString *str1 = @"中国第001店/义乌奔宝店";
//    [printer appendText:str1 alignment:HLTextAlignmentCenter];
//    [printer appendSeperatorLine];
//    
//
//    [printer appendText:@"地址:义乌市机场" alignment:HLTextAlignmentLeft];
//    [printer appendText:@"电话:0579-85527555" alignment:HLTextAlignmentLeft];
//    [printer appendSeperatorLine];
//    
//    [printer appendText:@"车主：你妹" alignment:HLTextAlignmentLeft];
//    [printer appendTitle:@"车牌：苏D12345" value:@"车架号：LX56357354736474"];
//    [printer appendText:@"车型：HJGGHGFUIU AODI" alignment:HLTextAlignmentLeft];
    
    
//    [printer appendLeftText:@"商品" middleText:@"数量" rightText:@"单价" isTitle:YES];
//    CGFloat total = 0.0;
//    for (NSDictionary *dict in self.goodsArray) {
//        [printer appendLeftText:dict[@"name"] middleText:dict[@"amount"] rightText:dict[@"price"] isTitle:NO];
//        total += [dict[@"price"] floatValue] * [dict[@"amount"] intValue];
//    }
//    
//    [printer appendSeperatorLine];
//    NSString *totalStr = [NSString stringWithFormat:@"%.2f",total];
//    [printer appendTitle:@"总计:" value:totalStr];
//    [printer appendTitle:@"实收:" value:@"100.00"];
//    NSString *leftStr = [NSString stringWithFormat:@"%.2f",100.00 - total];
//    [printer appendTitle:@"找零:" value:leftStr];
//    
//    [printer appendSeperatorLine];
//    // 二维码
//    [printer appendText:@"位图方式打印二维码" alignment:HLTextAlignmentCenter];
//    [printer appendQRCodeWithInfo:@"www.baidu.com"];
    [printer appendSeperatorLine];
    
    [printer appendLeftText:@"贵重物品：无" middleText:@"旧件返还：否" rightText:@"洗车服务：无" isTitle:YES];
    [printer appendSeperatorLine];
//    [printer appendText:@"指令方式打印二维码" alignment:HLTextAlignmentCenter];
//    [printer appendQRCodeWithInfo:@"www.baidu.com" size:12];
//    [printer appendSeperatorLine];
    
    // 图片
//    [printer appendImage:[UIImage imageNamed:@"vip.png"] alignment:HLTextAlignmentCenter maxWidth:500];
    [printer appendText:@"扫码领取会员卡" alignment:HLTextAlignmentCenter];
    //[printer appendFooter:nil];
    return printer;
}

- (void)printAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    HLPrinter *printInfo = [self getPrinter];
    
    if (_printBlock) {
        _printBlock(printInfo);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.goodsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    NSDictionary *dict = self.goodsArray[indexPath.row];
    
    cell.textLabel.text = dict[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"单价: %@元-------数量：%@",dict[@"price"], dict[@"amount"]];
    
    return cell;
}


@end
