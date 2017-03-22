//
//  BGStockBar.m
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#import "BGStockBar.h"

@interface BGStockBar ()

@property (nonatomic, copy) NSArray *titles;

@property (nonatomic, strong) NSMutableArray  *btnArray;

@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation BGStockBar


- (instancetype)initWithTitles:(NSArray<NSString *> *)titles {

    self = [super init];
    if (self) {
        
        _titles = titles;
        [self setupUI];
    }
    return self;
}


- (void)setupUI {

    
    [self initButtons];
}

- (void)initButtons {
    
    //按钮组
    __block UIButton *lastBtn;
    __block UIButton *firstBtn;
    self.btnArray = [NSMutableArray new];
    
    [self.titles enumerateObjectsUsingBlock:^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [self createBtnWithTitle:obj tag:idx+100];

        
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.width.equalTo(self).multipliedBy(1.f/self.titles.count);
            make.left.equalTo(lastBtn == nil ? self.mas_left : lastBtn.mas_right);
            make.height.equalTo(@(30));
        }];
        if (!lastBtn) firstBtn = btn;
        lastBtn = btn;
    }];
    
    //指示器
    UIView *indicatorView = [UIView new];
    indicatorView.backgroundColor = [UIColor clearColor];
    [self addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(2);
        make.width.equalTo(lastBtn.mas_width);
        make.top.equalTo(lastBtn.mas_bottom);
        make.centerX.equalTo(firstBtn.mas_centerX);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateBtnUI:nil newBtn:[self.subviews firstObject]];
    });

}

/**
 创建按钮
 
 @param title 标题
 @param tag tag
 
 @return 按钮
 */
- (UIButton *)createBtnWithTitle:(NSString *)title tag:(NSInteger)tag
{
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:BGBlueColor forState:UIControlStateNormal];
    [btn setTitleColor:BGWhiteColor forState:UIControlStateSelected];
    btn.tag = tag;
    [btn addTarget:self action:@selector(didClickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


/**
 按钮点击事件
 
 @param btn 被点击的按钮
 */
- (void)didClickBtnAction:(UIButton *)btn {
    if (self.selectedIndex != btn.tag-100) {
        self.userInteractionEnabled= NO;
        [self updateBtnUI:[self viewWithTag:self.selectedIndex+100] newBtn:btn];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.userInteractionEnabled= YES;
        });
    }
    
    if (self.clickBlock) {
        self.clickBlock(self.selectedIndex);
    }
}

/**
 更新UI
 
 @param oldBtn 原按钮
 @param newBtn 新按钮
 */
- (void)updateBtnUI: (UIButton *)oldBtn newBtn:(UIButton *)newBtn {
    
    oldBtn.selected = NO;
    oldBtn.backgroundColor = nil;
    [newBtn setSelected:YES];
    
    [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(newBtn.mas_centerX);
        make.height.equalTo(@2);
        make.width.equalTo(newBtn.mas_width);
        make.top.equalTo(newBtn.mas_bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    
    self.selectedIndex = newBtn.tag-100;
}


@end
