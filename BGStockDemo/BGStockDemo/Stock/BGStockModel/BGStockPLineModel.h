//
//  BGStockPLineModel.h
//  BGStockDemo
//
//  Created by Passion on 2017/2/27.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGStockPLineModel : NSObject

@property (nonatomic, copy) NSString  *TRADE_TIME;
@property (nonatomic, assign) CGFloat  PRICE;
@property (nonatomic, assign) CGFloat  V_TOTAL;
@property (nonatomic, assign) CGFloat  M_TOTAL;
@property (nonatomic, copy) NSString  *TTL_B_QTY;
@property (nonatomic, copy) NSString  *W_AVG_B_PX;
@property (nonatomic, copy) NSString  *TTL_O_QTY;
@property (nonatomic, copy) NSString  *W_AVG_O_PX;


@end
