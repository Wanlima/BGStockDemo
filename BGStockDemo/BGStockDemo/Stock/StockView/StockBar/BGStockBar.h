//
//  BGStockBar.h
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^StockBarClickBlock)(NSInteger);

@interface BGStockBar : UIView


@property (nonatomic, copy) StockBarClickBlock clickBlock;


- (instancetype)initWithTitles:(NSArray<NSString *> *)titles;


@end
