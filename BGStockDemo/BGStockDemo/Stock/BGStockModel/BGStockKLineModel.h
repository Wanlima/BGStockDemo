//
//  BGStockKLineModel.h
//  BGStockDemo
//
//  Created by Passion on 2017/2/27.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGStockKLineModel : NSObject

@property (nonatomic, copy) NSString  *TRADE_TIME;
@property (nonatomic, assign) CGFloat OPEN;
@property (nonatomic, assign) CGFloat  HIGH;
@property (nonatomic, assign) CGFloat  LOW;
@property (nonatomic, assign) CGFloat  CLOSE;
@property (nonatomic, assign) CGFloat  VOLUME;
@property (nonatomic, assign) CGFloat  MONEY;
@property (nonatomic, copy) NSString  *PAUSE_TYPE;
@property (nonatomic, assign) CGFloat PREV_PCLOSE;

@property (nonatomic, assign) CGFloat  MA5;
@property (nonatomic, assign) CGFloat  MA10;
@property (nonatomic, assign) CGFloat  MA20;

- (CGFloat)calculateMA:(NSInteger)days ValueWithStockDatas:(NSArray *)datas startIndex:(NSInteger)index;

@end
