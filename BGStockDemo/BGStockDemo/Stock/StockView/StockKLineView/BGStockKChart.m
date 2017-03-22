//
//  BGStockKChart.m
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "BGStockKChart.h"

static const CGFloat BGChartSpace = 20;//预留20的高度，使最大值不占满表格

@interface BGStockKChart ()
{

    CGFloat _maxPrice;//最高价
    CGFloat _minPrice;//最低价
    CGFloat _maxVolume;//最大成交量
    CGFloat _kChartHeight;//K线图的高度
    CGFloat _kChartPerHeight;//K线图的分度值
    CGFloat _volumeChartHeight;//成交量图的高度
    CGFloat _volumeChartPerHeight;//成交量图的分度值
    CGFloat _offScreenCount;//屏幕外绘制的个数
    CGFloat _startX;//开始绘制的x坐标值
    CGFloat _xScale;//缩放
}

@property (nonatomic, strong) UIView  *containerView;

@property (nonatomic, strong) UIScrollView  *bgScrollView;

@property (nonatomic, strong) CAShapeLayer  *backgroundLayer;

@property (nonatomic, strong) CAShapeLayer  *contentLayer;

@property (nonatomic, strong) NSArray  *showModels;

@property (nonatomic, assign) CGFloat candleWidth;

@property (nonatomic, strong) NSMutableArray *candleReuseArray;

@property (nonatomic, strong) NSMutableArray *volumeReuseArray;

@end

@implementation BGStockKChart


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
    [_containerView addSubview:_bgScrollView];
    [_bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.equalTo(_containerView);
    }];

    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressAction:)];
    [_bgScrollView addGestureRecognizer:press];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [_bgScrollView addGestureRecognizer:pinch];
}

- (void)reDraw {

    [self layoutIfNeeded];
    [self initializeAttributes];
    [self clearContent];
    [self drawBackgroundForm];
    [self reload];
}

- (void)reload {

    [self updateShowModelsInScreen];
    [self updateShowInformation];
    [self drawContents];
}

- (void)clearContent {

    [_backgroundLayer removeFromSuperlayer];
    _backgroundLayer = nil;
    
    [_contentLayer removeFromSuperlayer];
    _contentLayer = nil;
    
    [_containerView.layer addSublayer:self.backgroundLayer];
    [_bgScrollView.layer addSublayer:self.contentLayer];
}

#pragma mark DrawMethods

- (void)drawBackgroundForm {

    CAShapeLayer *formLayer = [CAShapeLayer layer];

    CGMutablePathRef mPath = CGPathCreateMutable();

    
    CGRect kChartRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*BGStockKLineRatio);
    
    CGPathAddRect(mPath, &CGAffineTransformIdentity, kChartRect);
    
    
    for (int i = 1; i < 4; i++) {
        
        CGFloat height = kChartRect.size.height/4*i;
        CGPathMoveToPoint(mPath, &CGAffineTransformIdentity, 0, height);
        CGPathAddLineToPoint(mPath, &CGAffineTransformIdentity, CGRectGetWidth(self.bounds), height);
    }
    
    
    CGRect volumeRect = CGRectMake(0, CGRectGetHeight(self.bounds)*(1-BGStockVolumeRatio), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*BGStockVolumeRatio);
    
    CGPathAddRect(mPath, &CGAffineTransformIdentity, volumeRect);

    formLayer.strokeColor = BGLineColor.CGColor;
    formLayer.path = mPath;
    
    CGPathRelease(mPath);
    
    [_backgroundLayer addSublayer:formLayer];
}


- (void)drawContents {

    
    
    CAShapeLayer *candlesLayer = [CAShapeLayer layer];
    CAShapeLayer *volumesLayer = [CAShapeLayer layer];
    
    [self.klineModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        
        
        
        
        
    }];
}



- (CAShapeLayer *)sigleCandleLayerWithKLineModel:(BGStockKLineModel *)model
                                       perHeight:(CGFloat)height
                                        position:(CGPoint)position
                                           scale:(CGFloat)scale
                                           index:(NSInteger)index {
    
    
    CAShapeLayer *candle = [CAShapeLayer layer];
    candle.position = CGPointMake(0, 0);
    
    CGFloat min = MIN(model.OPEN, model.CLOSE);
    CGFloat max = MAX(model.OPEN, model.CLOSE);
    
    CGMutablePathRef cgpath = CGPathCreateMutable();
    CGPathMoveToPoint(cgpath, nil, position.x, position.y);
    CGPathAddLineToPoint(cgpath, nil, position.x, position.y + (model.HIGH- max)*height);
    
    CGPathAddRect(cgpath, nil, CGRectMake(position.x - BGStockCandleWidth*scale/2, position.y + (model.HIGH - max)*height, BGStockCandleWidth*scale, (max - min)*height));
    
    CGPathMoveToPoint(cgpath, nil, position.x, position.y + (model.HIGH - min)*height);
    CGPathAddLineToPoint(cgpath, nil, position.x, position.y + (model.HIGH - model.LOW)*height);
    
    
    //关闭隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    UIColor *color = BGRedColor;
    candle.fillColor = [UIColor clearColor].CGColor;
    
    if (model.OPEN < model.CLOSE) {
        
        color = BGGreenColor;
        candle.fillColor = color.CGColor;
    }
    
    candle.strokeColor = color.CGColor;
    candle.path =cgpath;
    [CATransaction commit];
    
    CGPathRelease(cgpath);
    return candle;
}



#pragma mark PrivateMethods


- (CGPoint)convertToPositionModelsWithXPosition:(CGFloat)startX
                                   drawLineModels:(BGStockKLineModel *)model
                                         maxValue:(CGFloat)maxValue
                                         minValue:(CGFloat)minValue {

    CGFloat pointX = 0;
    CGFloat pointY = 0;
    
    
    
    
    return CGPointMake(pointX, pointY);
}

- (void)initializeAttributes {

    _xScale = 1.f;
    _offScreenCount = 4;
    _kChartHeight = CGRectGetHeight(self.bounds)*BGStockKLineRatio;
    _volumeChartHeight = CGRectGetHeight(self.bounds)*BGStockVolumeRatio;





}


- (void)updateShowModelsInScreen {

    CGFloat chartWidth = CGRectGetWidth(self.bounds);
    CGFloat singleWidth = _candleWidth*_xScale + BGStockCandleGap;
    NSInteger count = (int)ceil(chartWidth/singleWidth);
    
    CGFloat realOffsetX = _bgScrollView.contentOffset.x;
    CGFloat offsetX = realOffsetX < 0 ? 0 : realOffsetX;
    
    NSUInteger leftCount = ABS(offsetX)/singleWidth;
    
    if (leftCount >= _offScreenCount) {
        
        leftCount -= _offScreenCount;
        _startX = realOffsetX-singleWidth*_offScreenCount;
    }else {
        
        leftCount = 0;
        _startX = 0;
    }
    
    NSInteger length;
    
    if (leftCount+count+_offScreenCount*2 < self.klineModels.count) {
        
        length = count+_offScreenCount*2;
    }else {
        
        if (leftCount > self.klineModels.count) {
            
            length = count;
            leftCount = self.klineModels.count - count;
        }
        length = self.klineModels.count - leftCount;
    }
    
    NSArray *showModels = [self.klineModels subarrayWithRange:NSMakeRange(leftCount, length)];
    
    self.showModels = showModels;
}




- (void)updateShowInformation {

    
    CGFloat max = [[self.showModels valueForKeyPath:@"@max.HIGH"] floatValue];
    CGFloat maxMA5 = [[self.showModels valueForKeyPath:@"@max.MA5" ] floatValue];
    CGFloat maxMA10 = [[self.showModels valueForKeyPath:@"@max.MA10" ] floatValue];
    CGFloat maxMA20 = [[self.showModels valueForKeyPath:@"@max.MA20" ] floatValue];
    
    max = MAX(MAX(MAX(maxMA5, maxMA10), maxMA20), max);
    
    
    __block CGFloat min = [[self.showModels valueForKeyPath:@"@min.LOW"] floatValue];
    
    [self.showModels enumerateObjectsUsingBlock:^(BGStockKLineModel*  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        min = MIN(MIN(MIN(model.MA5, model.MA10), model.MA20), min);
    }];
    
    _maxPrice = max;
    _minPrice = min;
    _maxVolume = [[self.showModels valueForKeyPath:@"@max.VOLUME" ] floatValue];
    
    _kChartPerHeight = (CGRectGetHeight(self.bounds)*BGStockKLineRatio - BGChartSpace)/(_maxPrice - _minPrice);
    
    _volumeChartPerHeight = (CGRectGetHeight(self.bounds)*BGStockVolumeRatio - BGChartSpace)/_maxVolume;
    
    _bgScrollView.contentSize = CGSizeMake((self.klineModels.count+1)*(BGStockCandleWidth + BGStockCandleGap)*_xScale, self.bounds.size.height);
}


#pragma mark UserActions

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {





}

- (void)pressAction:(UILongPressGestureRecognizer *)press {






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

- (NSMutableArray *)candleReuseArray {

    if (!_candleReuseArray) {
        _candleReuseArray = [NSMutableArray new];
    }
    return _candleReuseArray;
}

- (NSMutableArray *)volumeReuseArray {

    if (!_volumeReuseArray) {
        _volumeReuseArray  = [NSMutableArray new];
    }
    return _volumeReuseArray;
}

@end
