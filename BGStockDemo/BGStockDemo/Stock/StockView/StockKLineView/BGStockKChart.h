//
//  BGStockKChart.h
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGStockKChart : UIView


@property (nonatomic, strong) NSArray  *klineModels;


- (void)reDraw;

@end
