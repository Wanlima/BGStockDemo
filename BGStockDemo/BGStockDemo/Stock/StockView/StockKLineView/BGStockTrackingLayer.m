//
//  BGStockTrackingLayer.m
//  BGStockDemo
//
//  Created by Passion on 2017/3/10.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "BGStockTrackingLayer.h"


@interface BGStockTrackingLayer ()


@property (nonatomic, strong) CATextLayer  *price;

@property (nonatomic, strong) CATextLayer  *time;


@end

@implementation BGStockTrackingLayer


- (void)refreshWithModel:(BGStockKLineModel *)model acrossPosition:(CGPoint)across {
    
    _showModel = model;
    _acrossPosition = across;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, _acrossPosition.y)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, _acrossPosition.y)];
    
    [path moveToPoint:CGPointMake(_acrossPosition.x, 0)];
    [path addLineToPoint:CGPointMake(_acrossPosition.x, self.bounds.size.height)];
    
    self.strokeColor = [UIColor whiteColor].CGColor;
    self.path = path.CGPath;

    
    //关闭隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName:HEX(0xffffff)
                                 };
    CGRect frame = [self rectOfNSString:[NSString stringWithFormat:@"%.2f",_showModel.OPEN] attribute:attributes];
    frame.origin.x = 0;
    frame.origin.y = _acrossPosition.y - CGRectGetHeight(frame)/2;
    self.price.frame = frame;
    self.price.string = [NSString stringWithFormat:@"%.2f",_showModel.OPEN];
    
    
    frame = [self rectOfNSString:[NSString stringWithFormat:@"%@",[_showModel.TRADE_TIME substringToIndex:10]] attribute:attributes];
    frame.origin.x = _acrossPosition.x - CGRectGetWidth(frame)/2;
    frame.origin.y = self.bounds.size.height - CGRectGetHeight(frame);
    self.time.frame = frame;
    self.time.string = [NSString stringWithFormat:@"%@",[_showModel.TRADE_TIME substringToIndex:10]];
    
    [CATransaction commit];
}

- (CATextLayer *)price {

    if (!_price) {
        
        _price = [self createTextLayerWithString:nil fontSize:12 foregroundColor:HEX(0xffffff) frame:CGRectZero];
        _price.backgroundColor = [UIColor blueColor].CGColor;
        [self addSublayer:_price];

    }
    
    return _price;
}


- (CATextLayer *)time {

    if (!_time) {
        
        _time = [self createTextLayerWithString:nil fontSize:12 foregroundColor:HEX(0xffffff) frame:CGRectZero];
        _time.backgroundColor = [UIColor blueColor].CGColor;
        [self addSublayer:_time];
    }
    
    return _time;
}

- (CATextLayer *)createTextLayerWithString:(NSString *)string fontSize:(CGFloat)size foregroundColor:(UIColor *)color frame:(CGRect)frame {
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = string;
    textLayer.fontSize = size;
    textLayer.foregroundColor = color.CGColor;
    textLayer.frame = frame;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
}

- (CGRect)rectOfNSString:(NSString *)string attribute:(NSDictionary *)attribute {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil];
    return rect;
}


@end
