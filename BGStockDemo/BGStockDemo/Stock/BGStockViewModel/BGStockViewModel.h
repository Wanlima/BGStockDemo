//
//  BGStockViewModel.h
//  BGStockDemo
//
//  Created by Passion on 2017/2/27.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGStockViewModel : NSObject

@property (nonatomic, strong) NSMutableArray  *plineModels;


+ (NSArray *)fetchPLineDatas;

+ (NSArray *)fetchKLineDatasType:(NSInteger)type;

@end
