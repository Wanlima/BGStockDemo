//
//  ViewController.m
//  BGStockDemo
//
//  Created by Passion on 2017/2/27.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()<BGStockDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    BGStockView *stock = [[BGStockView alloc] initWithFrame:CGRectZero dataSource:self];
    [self.view addSubview:stock];
    
    [stock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(260);
    }];
}

- (NSArray *)titleOfStockViewItems {

    return @[@"分时",@"一分",@"日K",@"周K",@"月K",@"分钟"];
}

- (void)stockView:(BGStockView *)stockView selectedAtIndex:(NSInteger)index {


    NSLog(@"选中index==%ld",index);
}

- (BGStockChartType)stockView:(BGStockView *)stockView typeAtIndex:(NSInteger)index {

    return  index == 0?BGStockChartTypeTimeChart:BGStockChartTypeKChart;
}

- (NSArray *)stockView:(BGStockView *)stockView dataAtIndex:(NSInteger)index {

    if (index == 0) {
        return [BGStockViewModel fetchPLineDatas];
    }else {
        return [BGStockViewModel fetchKLineDatasType:index-1];
    }
}


@end
