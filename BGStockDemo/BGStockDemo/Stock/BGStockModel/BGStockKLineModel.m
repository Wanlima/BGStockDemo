//
//  BGStockKLineModel.m
//  BGStockDemo
//
//  Created by Passion on 2017/2/27.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "BGStockKLineModel.h"

@implementation BGStockKLineModel


- (CGFloat)calculateMA:(NSInteger)days ValueWithStockDatas:(NSArray *)datas startIndex:(NSInteger)index{
    
    CGFloat averageValue = 0;
    
    NSArray *array = [datas subarrayWithRange:NSMakeRange(index-days + 1, days)];
    
    averageValue = [[array valueForKeyPath:@"@avg.CLOSE"] floatValue];
    
    return averageValue;
}


- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key {



}

@end
