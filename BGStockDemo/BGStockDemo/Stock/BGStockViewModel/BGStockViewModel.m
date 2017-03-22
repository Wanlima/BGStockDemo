//
//  BGStockViewModel.m
//  BGStockDemo
//
//  Created by Passion on 2017/2/27.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "BGStockViewModel.h"
#import "BGStockPLineModel.h"
#import "BGStockKLineModel.h"

@implementation BGStockViewModel



+ (NSArray *)fetchPLineDatas {
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Pline" ofType:@"txt"]];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
     NSArray *datas = [[dic[@"600330.SS"] reverseObjectEnumerator] allObjects];
    
    NSMutableArray *array = [NSMutableArray new];
    
    [datas enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BGStockPLineModel *plineModel = [[BGStockPLineModel alloc] init];
        [plineModel setValuesForKeysWithDictionary:dict];
        [array addObject:plineModel];
        
    }];
    return [array copy];
}

+ (NSArray *)fetchKLineDatasType:(NSInteger)type {

    type = type>0?type:1;
    NSString *fileName = [NSString stringWithFormat:@"kline%ld",type];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"]];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *datas = [[dic[@"600330.SS"] reverseObjectEnumerator] allObjects];
    
    
    NSMutableArray *array = [NSMutableArray new];
    
    [datas enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BGStockKLineModel *klineModel = [[BGStockKLineModel alloc] init];
        [klineModel setValuesForKeysWithDictionary:dict];
        
        if (idx >= 4) {
            klineModel.MA5 = [klineModel calculateMA:5 ValueWithStockDatas:datas startIndex:idx];
        }
        
        if (idx >= 9) {
            klineModel.MA10 = [klineModel calculateMA:10 ValueWithStockDatas:datas startIndex:idx];
        }
        
        if (idx >= 19) {
            klineModel.MA20 = [klineModel calculateMA:20 ValueWithStockDatas:datas startIndex:idx];
            
        }
        
        if (![klineModel.PAUSE_TYPE isEqualToString:@"AP"]) {
            [array addObject:klineModel];
        }
    }];
    return [array copy];
}




@end
