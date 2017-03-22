//
//  BGStockTrackingLayer.h
//  BGStockDemo
//
//  Created by Passion on 2017/3/10.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BGStockKLineModel.h"

@interface BGStockTrackingLayer : CAShapeLayer


@property (nonatomic, strong) BGStockKLineModel  *showModel;

@property (nonatomic, assign) CGPoint acrossPosition;

@property (nonatomic, assign) CGPoint  showPosition;


- (void)refreshWithModel:(BGStockKLineModel *)model acrossPosition:(CGPoint)across;


@end
