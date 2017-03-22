//
//  BGStockView.m
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "BGStockView.h"

static const CGFloat BGStockViewBarHeight = 32;

@interface BGStockView ()

{

    NSInteger _chartCount;
}
@property (nonatomic, strong) UIView  *mainView;

@property (nonatomic, strong) BGStockBar  *topBar;

@property (nonatomic, strong) UIView  *containerView;

@property (nonatomic, strong) NSMutableArray  *stockViews;

@end

@implementation BGStockView

- (instancetype)initWithFrame:(CGRect)frame {

    return [self initWithFrame:frame dataSource:nil];
}


- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<BGStockDataSource>)dataSource {

    self = [super initWithFrame:frame];
    if (self) {
        
        _selectedIndex = 0;
        _stockViews = [NSMutableArray new];
        self.dataSource = dataSource;
        [self setupUI];
    }
    return self;
}


- (void)setupUI {

    _mainView = [UIView new];
    _mainView.backgroundColor = [UIColor blackColor];
    [self addSubview:_mainView];
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self initTopBar];
    [self initContainerView];
}


- (void)initTopBar {

    if ([self.dataSource respondsToSelector:@selector(titleOfStockViewItems)]) {
        
        NSArray *titles = [self.dataSource titleOfStockViewItems];
        
        _chartCount = titles.count;
        
        _topBar = [[BGStockBar alloc] initWithTitles:titles];
        
        [_mainView addSubview:_topBar];
        
        [_topBar mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(_mainView).offset(8);
            make.left.equalTo(_mainView).offset(2);
            make.right.equalTo(_mainView).offset(-2);
            make.height.mas_equalTo(BGStockViewBarHeight);
        }];
        
        
        WEAK_SELF;
        [_topBar setClickBlock:^(NSInteger index){

            [weakSelf topBarDidSelectedAtIndex:index];
        }];
    }

}

- (void)initContainerView {

    _containerView = [UIView new];
    [_mainView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topBar.mas_bottom).offset(3);
        make.left.right.bottom.equalTo(_mainView);
    }];
    
    for (int i = 0; i < _chartCount; i++) {
        
        BGStockChartType type = [self.dataSource stockView:self typeAtIndex:i];
    
        UIView *stockChart;
    
        if (type == BGStockChartTypeTimeChart) {
        
            stockChart = [[BGStockTimeChart alloc] init];
        }else{
        
            stockChart = [[BGStockKChart alloc] init];
        }
        
        [_containerView addSubview:stockChart];
        [stockChart mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(_containerView).offset(3);
            make.left.equalTo(_containerView).offset(2);
            make.right.equalTo(_containerView).offset(-2);
            make.bottom.equalTo(_containerView).offset(-2);
        }];
        
        stockChart.hidden = (i!=_selectedIndex);
        
        [_stockViews addObject:stockChart];
    }
}


- (void)reloadData {

    NSInteger index = _selectedIndex;
    
    if ([self.stockViews[index] isKindOfClass:[BGStockKChart class]]) {
        
        BGStockKChart *stockView = (BGStockKChart *)(self.stockViews[index]);
        
        stockView.klineModels = [self.dataSource stockView:self dataAtIndex:index];
        
        [stockView reDraw];
    }
    if ([self.stockViews[index] isKindOfClass:[BGStockTimeChart class]]) {
        
        BGStockTimeChart *stockView = (BGStockTimeChart *)(self.stockViews[index]);
        [stockView reDraw];
    }
}




#pragma mark Actions

- (void)topBarDidSelectedAtIndex:(NSInteger)index {

    UIView *currentShowView = self.stockViews[_selectedIndex];
    currentShowView.hidden = YES;
    currentShowView = self.stockViews[index];
    currentShowView.hidden = NO;
    _selectedIndex = index;
    [self reloadData];
    
    if ([self.dataSource respondsToSelector:@selector(stockView:selectedAtIndex:)]) {
        
        [self.dataSource stockView:self selectedAtIndex:index];
    }
}

@end
