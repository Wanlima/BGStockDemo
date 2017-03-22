//
//  BGStockKChart.m
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "BGStockKChart.h"

typedef NS_ENUM(NSInteger, BGStockMALineType) {
    
    BGStockMALineTypeFive = 5,
    BGStockMALineTypeTen = 10,
    BGStockMALineTypeTwenty = 20
};

/**
 *  K线图缩放界限
 */
static const CGFloat BGStockWidthScaleBound = 0.03;

/**
 *  K线的缩放因子
 */
static const CGFloat BGStockWidthScaleFactor = 0.06;

/**
 *  预留20的高度，使最大值不占满表格
 */
static const CGFloat BGChartSpace = 20;

@interface BGStockKChart ()<UIScrollViewDelegate>
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
    CGFloat _oldContentOffsetX;
}

@property (nonatomic, strong) UIView  *containerView;

@property (nonatomic, strong) UIScrollView  *bgScrollView;

@property (nonatomic, strong) CAShapeLayer  *backgroundLayer;

@property (nonatomic, strong) BGStockTrackingLayer  *trackingLayer;

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
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.delegate = self;
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
    [self drawBackgroundForm];
    [self reload];
}

- (void)reload {

    [self clearContent];
    [self updateShowModelsInScreen];
    [self updateShowInformation];
    [self drawCoordinates];
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
    formLayer.fillColor = nil;
    formLayer.path = mPath;
    
    CGPathRelease(mPath);
    
    formLayer.zPosition = -1;
   [self.layer addSublayer:formLayer];
}

- (void)drawCoordinates {
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName:HEX(0xffffff)
                                 };
    
    
    CGFloat perValue = (_maxPrice - _minPrice)/4;
    
    //价格刻度
    for (int i = 0; i < 5; i++) {
        
        CGFloat value = _minPrice+perValue*i;
        
        CGRect frame = [self rectOfNSString:[NSString stringWithFormat:@"%.2f",value] attribute:attributes];
        
        if (i == 0) {
            
            frame.origin.y = _kChartHeight - _kChartHeight*i/4 - frame.size.height;
        }else if (i == 4){
            
            frame.origin.y = _kChartHeight - _kChartHeight*i/4;
        }else {
            
            frame.origin.y = _kChartHeight - _kChartHeight*i/4 - frame.size.height/2;
        }
        
        CATextLayer *textLayer = [self createTextLayerWithString:[NSString stringWithFormat:@"%.2f",value] fontSize:12 foregroundColor:HEX(0xffffff) frame:frame];
        
        [_backgroundLayer addSublayer:textLayer];
    }
    
    //日均线
    BGStockKLineModel *model = self.showModels.lastObject;
    
    CGRect frame= [self rectOfNSString:[NSString stringWithFormat:@"MA5:%.2f",model.MA5] attribute:attributes];
    CATextLayer *ma5 = [self createTextLayerWithString:[NSString stringWithFormat:@"MA5:%.2f",model.MA5] fontSize:12 foregroundColor:BGMA5Color frame:frame];
    frame.origin.x = 50;
    ma5.frame = frame;
    
    [_backgroundLayer addSublayer:ma5];
    
    frame= [self rectOfNSString:[NSString stringWithFormat:@"MA10:%.2f",model.MA10] attribute:attributes];
    CATextLayer *ma10 = [self createTextLayerWithString:[NSString stringWithFormat:@"MA10:%.2f",model.MA10] fontSize:12 foregroundColor:BGMA10Color frame:frame];
    frame.origin.x = CGRectGetMaxX(ma5.frame)+10;
    ma10.frame = frame;
    
    [_backgroundLayer addSublayer:ma10];
    
    frame= [self rectOfNSString:[NSString stringWithFormat:@"MA20:%.2f",model.MA20] attribute:attributes];
    CATextLayer *ma20 = [self createTextLayerWithString:[NSString stringWithFormat:@"MA20:%.2f",model.MA20] fontSize:12 foregroundColor:BGMA20Color frame:frame];
    frame.origin.x = CGRectGetMaxX(ma10.frame)+10;
    ma20.frame = frame;
    
    [_backgroundLayer addSublayer:ma20];
    
    //成交量
    frame = [self rectOfNSString:[NSString stringWithFormat:@"%.2f",_maxVolume] attribute:attributes];
    frame.origin.y = self.bounds.size.height*0.7;
    
    CATextLayer *textLayer = [self createTextLayerWithString:[NSString stringWithFormat:@"%.2f",_maxVolume/10000.0] fontSize:12 foregroundColor:HEX(0xffffff) frame:frame];
    [_backgroundLayer addSublayer:textLayer];
    
    frame = [self rectOfNSString:[NSString stringWithFormat:@"万手"] attribute:attributes];
    frame.origin.y = self.bounds.size.height - frame.size.height;;
    textLayer = [self createTextLayerWithString:[NSString stringWithFormat:@"万手"] fontSize:12 foregroundColor:HEX(0xffffff) frame:frame];
    
    [_backgroundLayer addSublayer:textLayer];
}


- (void)drawContents {

    CAShapeLayer *candlesLayer = [CAShapeLayer layer];
    CAShapeLayer *volumesLayer = [CAShapeLayer layer];
    
    
    CAShapeLayer *ma5Layer = [CAShapeLayer layer];
    CAShapeLayer *ma10Layer = [CAShapeLayer layer];
    CAShapeLayer *ma20Layer = [CAShapeLayer layer];
    
    CGMutablePathRef ma5Path = CGPathCreateMutable();
    CGMutablePathRef ma10Path = CGPathCreateMutable();
    CGMutablePathRef ma20Path = CGPathCreateMutable();
    
    
    
    __block BGStockKLineModel *preModel;
    [self.showModels enumerateObjectsUsingBlock:^(BGStockKLineModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
       
        //绘制蜡烛
        CGPoint position = CGPointMake(_startX + _candleWidth*_xScale/2+(_candleWidth*_xScale+BGStockCandleGap)*idx, _kChartHeight - (model.HIGH - _minPrice)*_kChartPerHeight);
        
        CAShapeLayer *candle = [self sigleCandleLayerWithKLineModel:model perHeight:_kChartPerHeight position:position scale:_xScale index:idx];
        
        [candlesLayer addSublayer:candle];
        
        
        //日均线
        [self drawMALineWithType:BGStockMALineTypeFive path:ma5Path value:model.MA5 index:idx];
        [self drawMALineWithType:BGStockMALineTypeTen path:ma10Path value:model.MA10 index:idx];
        [self drawMALineWithType:BGStockMALineTypeTwenty path:ma20Path value:model.MA20 index:idx];
        //绘制成交量
        position = CGPointMake(_startX + _candleWidth*_xScale/2+(_candleWidth*_xScale+BGStockCandleGap)*idx, self.bounds.size.height - model.VOLUME*_volumeChartPerHeight);
        
        CAShapeLayer *volume = [self sigleVolumeLayerWithKLineModel:model preModel:preModel perHeight:_volumeChartPerHeight position:position scale:_xScale index:idx];
        
        [volumesLayer addSublayer:volume];
        preModel = model;
        
    }];
    
    [_contentLayer addSublayer:candlesLayer];
    
    ma5Layer.path = ma5Path;
    ma5Layer.fillColor = nil;
    ma5Layer.strokeColor = BGMA5Color.CGColor;
    
    ma10Layer.path = ma10Path;
    ma10Layer.fillColor = nil;
    ma10Layer.strokeColor = BGMA10Color.CGColor;
    
    ma20Layer.path = ma20Path;
    ma20Layer.fillColor = nil;
    ma20Layer.strokeColor = BGMA20Color.CGColor;
    
    CGPathRelease(ma5Path);
    CGPathRelease(ma10Path);
    CGPathRelease(ma20Path);
    
    [_contentLayer addSublayer:ma5Layer];
    [_contentLayer addSublayer:ma10Layer];
    [_contentLayer addSublayer:ma20Layer];
    
    [_contentLayer addSublayer:volumesLayer];
}

- (void)drawMALineWithType:(BGStockMALineType)type
                      path:(CGMutablePathRef)path
                     value:(CGFloat)value
                     index:(NSInteger)index {

    NSInteger startIndex = _startX/((_candleWidth + BGStockCandleGap)*_xScale);
    CGFloat space = _startX + _candleWidth*_xScale*0.5 + index*(_candleWidth*_xScale+ BGStockCandleGap);
    CGFloat startY = _kChartHeight - (value - _minPrice)*_kChartPerHeight;
    if (startIndex >= type - 1) {
        
        if (index == 0) {
            
            CGPathMoveToPoint(path, &CGAffineTransformIdentity, space, startY);
        }else {
            
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, space, startY);
        }
        
    }else {
        
        if (startIndex + index == type - 1) {
            
            CGPathMoveToPoint(path, &CGAffineTransformIdentity, space, startY);
        }else if(startIndex + index > type - 1){
            
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, space, startY);
        }
    }
}



- (CAShapeLayer *)sigleCandleLayerWithKLineModel:(BGStockKLineModel *)model
                                       perHeight:(CGFloat)height
                                        position:(CGPoint)position
                                           scale:(CGFloat)scale
                                           index:(NSInteger)index {
    //复用
    CAShapeLayer *candleLayer;
    if (index < self.candleReuseArray.count) {
        
        candleLayer = [self.candleReuseArray objectAtIndex:index];
        [candleLayer removeFromSuperlayer];
    }
    
    if (!candleLayer) {
        
        candleLayer = [CAShapeLayer layer];
        candleLayer.position = CGPointMake(0, 0);
        [self.candleReuseArray addObject:candleLayer];
    }


    CGFloat min = MIN(model.OPEN, model.CLOSE);
    CGFloat max = MAX(model.OPEN, model.CLOSE);
    
    CGMutablePathRef cgpath = CGPathCreateMutable();
    CGPathMoveToPoint(cgpath, nil, position.x, position.y);
    CGPathAddLineToPoint(cgpath, nil, position.x, position.y + (model.HIGH- max)*height);
    
    CGPathAddRect(cgpath, nil, CGRectMake(position.x - _candleWidth*scale/2, position.y + (model.HIGH - max)*height, _candleWidth*scale, (max - min)*height));
    
    CGPathMoveToPoint(cgpath, nil, position.x, position.y + (model.HIGH - min)*height);
    CGPathAddLineToPoint(cgpath, nil, position.x, position.y + (model.HIGH - model.LOW)*height);
    
    
    //关闭隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    UIColor *color = BGRedColor;
    candleLayer.fillColor = [UIColor clearColor].CGColor;
    
    if (model.OPEN < model.CLOSE) {
        
        color = BGGreenColor;
        candleLayer.fillColor = color.CGColor;
    }
    
    candleLayer.strokeColor = color.CGColor;
    candleLayer.path =cgpath;
    [CATransaction commit];
    
    CGPathRelease(cgpath);
    return candleLayer;
}

- (CAShapeLayer *)maLineLayerWithType:(NSInteger)type
                          KLineModels:(NSArray<BGStockKLineModel *> *)models
                             minPrice:(CGFloat)minPrice
                            offHeight:(CGFloat)offHeight
                            perHeight:(CGFloat)height
                                scale:(CGFloat)scale
                               startX:(CGFloat)startx{
    
    
    CAShapeLayer *maLineLayer = [CAShapeLayer layer];
    maLineLayer.position = CGPointMake(0, 0);
    
    CGMutablePathRef mPath = CGPathCreateMutable();
    
    __block UIColor *color;
    
    NSInteger startIndex = startx/((_candleWidth*scale+ BGStockCandleGap));
    
    [models enumerateObjectsUsingBlock:^(BGStockKLineModel*  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat value;
        if (type == BGStockMALineTypeFive) {
            
            value = model.MA5;
            color = BGMA5Color;
        }else if (type == BGStockMALineTypeTen){
            
            value = model.MA10;
            color = BGMA10Color;
        }else{
            
            value = model.MA20;
            color = BGMA20Color;
        }
        
        CGFloat space = startx + _candleWidth*scale*0.5 + idx*(_candleWidth*scale+ BGStockCandleGap);
        
        if (value != 0) {
            
            CGFloat startY = offHeight - (value - minPrice)*height;
            
            if (startIndex >= type - 1) {
                
                if (idx == 0) {
                    
                    CGPathMoveToPoint(mPath, nil, space, startY);
                }else {
                    
                    CGPathAddLineToPoint(mPath, nil, space, startY);
                }
                
            }else {
                
                if (startIndex + idx == type - 1) {
                    
                    CGPathMoveToPoint(mPath, nil, space, startY);
                }else if(startIndex + idx > type - 1){
                    
                    CGPathAddLineToPoint(mPath, nil, space, startY);
                }
            }
        }
    }];
    
    maLineLayer.path = mPath;
    maLineLayer.fillColor = nil;
    maLineLayer.strokeColor = color.CGColor;
    
    return maLineLayer;
}

- (CAShapeLayer *)sigleVolumeLayerWithKLineModel:(BGStockKLineModel *)model
                                        preModel:(BGStockKLineModel *)preModel
                                       perHeight:(CGFloat)height
                                        position:(CGPoint)position
                                           scale:(CGFloat)scale
                                           index:(NSInteger)index{
    
    CAShapeLayer *volume;
    if (index < self.volumeReuseArray.count) {
        
        volume = [self.volumeReuseArray objectAtIndex:index];
        [volume removeFromSuperlayer];
    }
    
    if (!volume) {
        
        volume = [CAShapeLayer layer];
        volume.position = CGPointMake(0, 0);
        [self.volumeReuseArray addObject:volume];
    }
    
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathAddRect(mPath, nil, CGRectMake(position.x - _candleWidth*scale/2, position.y, _candleWidth*scale, model.VOLUME*height));
    //关闭隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    UIColor *fillColor;
    
    if (model.MONEY > preModel.MONEY) {
        
        fillColor = BGGreenColor;
    }else {
        fillColor = BGRedColor;
    }
    volume.fillColor = fillColor.CGColor;
    volume.path = mPath;
    [CATransaction commit];
    
    return volume;
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
    _candleWidth = BGStockCandleMinWidth;
    _offScreenCount = 4;
    _oldContentOffsetX = 0;
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
    
    _bgScrollView.contentSize = CGSizeMake((self.klineModels.count+1)*(_candleWidth + BGStockCandleGap)*_xScale, self.bounds.size.height);
}


#pragma mark UserActions
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    if (scrollView.contentOffset.x < 0) {
        
        if (scrollView.contentOffset.x < -60) {
            
            NSLog(@"向前请求数据");
        }
        return;
    }
    
    CGFloat difValue = ABS(_bgScrollView.contentOffset.x - _oldContentOffsetX);
    
    if(difValue >= (_candleWidth*_xScale+BGStockCandleGap))
    {
        _oldContentOffsetX = _bgScrollView.contentOffset.x;
        
        [self reload];
    }
}



- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {

    static CGFloat oldScale = 1.0f;
    CGFloat difValue = pinch.scale - oldScale;
    
    if(ABS(difValue) > BGStockWidthScaleBound) {
        if( pinch.numberOfTouches == 2 ) {
            
            CGPoint p1 = [pinch locationOfTouch:0 inView:self.bgScrollView];
            CGPoint p2 = [pinch locationOfTouch:1 inView:self.bgScrollView];
            CGFloat centerX = (p1.x+p2.x)/2;
            
            CGFloat oldLeftArrCount = ABS(centerX + BGStockCandleGap) / (BGStockCandleGap + _candleWidth);
            
            _candleWidth = _candleWidth * (difValue > 0 ? (1 + BGStockWidthScaleFactor) : (1 - BGStockWidthScaleFactor));
            
            if (_candleWidth<BGStockCandleMinWidth) {
                
                _candleWidth = BGStockCandleMinWidth;
            }else if (_candleWidth > BGStockCandleMaxWidth){
                
                _candleWidth = BGStockCandleMaxWidth;
            }

            CGFloat newLeftDistance = oldLeftArrCount * _candleWidth + (oldLeftArrCount - 1) * BGStockCandleGap;
    
            if ( self.klineModels.count * _candleWidth + (self.klineModels.count + 1) * BGStockCandleGap > self.bgScrollView.bounds.size.width ) {
                CGFloat newOffsetX = newLeftDistance - (centerX - self.bgScrollView.contentOffset.x);
                self.bgScrollView.contentOffset = CGPointMake(newOffsetX > 0 ? newOffsetX : 0 , self.bgScrollView.contentOffset.y);
            } else {
                self.bgScrollView.contentOffset = CGPointMake(0 , self.bgScrollView.contentOffset.y);
            }
    
            [self reload];
        }
    }
}

- (void)pressAction:(UILongPressGestureRecognizer *)press {

    CGPoint location = [press locationInView:self];
    CGPoint p = [self convertPoint:location toView:_bgScrollView];
    
    if (p.y < 0 || p.y > _bgScrollView.contentSize.height) {
        
        self.trackingLayer.hidden = YES;
        return;
    }
    
    NSInteger index = p.x/((_candleWidth*_xScale+BGStockCandleGap));
    
    if (index >= self.klineModels.count) {
        
        self.trackingLayer.hidden = YES;
        return;
    }
    
    BGStockKLineModel *model = self.klineModels[index];
    
    if (press.state == UIGestureRecognizerStateChanged|| press.state == UIGestureRecognizerStateBegan) {
        
        self.trackingLayer.hidden = NO;
        [self.trackingLayer refreshWithModel:model acrossPosition:location];
        
    }else if(press.state == UIGestureRecognizerStateEnded){
        
        self.trackingLayer.hidden = YES;
        
    }
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
- (CAShapeLayer *)trackingLayer {
    
    if (!_trackingLayer) {
        
        BGStockTrackingLayer *tracking = [BGStockTrackingLayer layer];
        tracking.position = CGPointMake(0, 0);
        tracking.frame = self.bounds;
        [self.layer addSublayer:tracking];
        _trackingLayer = tracking;
    }
    return _trackingLayer;
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
