//
//  BGStockView.h
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, BGStockChartType) {

    BGStockChartTypeKChart = 1,//K线图
    BGStockChartTypeTimeChart  //分时图
};


@class BGStockView;

@protocol BGStockDataSource <NSObject>

@required

- (NSArray *)titleOfStockViewItems;

- (void)stockView:(BGStockView *)stockView selectedAtIndex:(NSInteger)index;

- (BGStockChartType)stockView:(BGStockView *)stockView typeAtIndex:(NSInteger)index;

- (NSArray *)stockView:(BGStockView *)stockView dataAtIndex:(NSInteger)index;

@end



@interface BGStockView : UIView

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, weak) id<BGStockDataSource>  dataSource;


- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<BGStockDataSource>)dataSource;

- (void)reloadData;

@end
