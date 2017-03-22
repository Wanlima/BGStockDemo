//
//  BGStockTimeChart.m
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "BGStockTimeChart.h"

@interface BGStockTimeChart ()

@property (nonatomic, strong) UIView  *containerView;

@property (nonatomic, strong) UIScrollView  *bgScrollView;

@property (nonatomic, strong) CAShapeLayer  *backgroundLayer;

@property (nonatomic, strong) CAShapeLayer  *contentLayer;

@end

@implementation BGStockTimeChart

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    
    _containerView = [UIView new];
    [self addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self);
    }];
    
    _bgScrollView = [[UIScrollView alloc] init];
    _bgScrollView.scrollEnabled = NO;
    [_containerView addSubview:_bgScrollView];
    [_bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(_containerView);
    }];
    
}

- (void)reDraw {
    
    [self layoutIfNeeded];
    [_backgroundLayer removeFromSuperlayer];
    _backgroundLayer = nil;
    
    [_contentLayer removeFromSuperlayer];
    _contentLayer = nil;
    
    [_containerView.layer addSublayer:self.backgroundLayer];
    [_bgScrollView.layer addSublayer:self.contentLayer];
    
    //1.绘制背景
    [self drawBackgroundForm];
    
    
}

- (void)reload {
    
    
    
    
    
}

#pragma mark DrawMethods

- (void)drawBackgroundForm {
    
    CAShapeLayer *formLayer = [CAShapeLayer layer];
    
    CGMutablePathRef mPath = CGPathCreateMutable();
    
    
    CGRect kChartRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*BGStockKLineRatio);
    CGRect volumeRect = CGRectMake(0, CGRectGetHeight(self.bounds)*(1-BGStockVolumeRatio), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*BGStockVolumeRatio);
    
    //绘制横线
    for (int i = 1; i < 4; i++) {
        
        CGFloat height = kChartRect.size.height/4*i;
        
        CGPathMoveToPoint(mPath, &CGAffineTransformIdentity, 0, height);
        CGPathAddLineToPoint(mPath, &CGAffineTransformIdentity, CGRectGetWidth(self.bounds), height);
    }
    
    //绘制竖线
    for (int i = 1; i < 4; i++) {
        
        CGFloat width = kChartRect.size.width/4*i;
        
        CGPathMoveToPoint(mPath, &CGAffineTransformIdentity, width, 0);
        CGPathAddLineToPoint(mPath, &CGAffineTransformIdentity, width, CGRectGetMaxY(kChartRect));
        
        CGPathMoveToPoint(mPath, &CGAffineTransformIdentity, width, CGRectGetMinY(volumeRect));
        CGPathAddLineToPoint(mPath, &CGAffineTransformIdentity, width, CGRectGetMaxY(volumeRect));
    }
    
    CGPathAddRect(mPath, &CGAffineTransformIdentity, kChartRect);
    CGPathAddRect(mPath, &CGAffineTransformIdentity, volumeRect);
    

    formLayer.strokeColor = BGLineColor.CGColor;
    formLayer.fillColor = [UIColor clearColor].CGColor;
    formLayer.path = mPath;
    
    CGPathRelease(mPath);
    
    [_backgroundLayer addSublayer:formLayer];
}







#pragma mark LazyLoading

- (CAShapeLayer *)backgroundLayer {
    
    if (!_backgroundLayer) {
        _backgroundLayer = [CAShapeLayer layer];
    }
    return _backgroundLayer;
}

- (CAShapeLayer *)contentLayer {
    
    if (!_contentLayer) {
        _contentLayer = [CAShapeLayer layer];
    }
    return _contentLayer;
}


@end
