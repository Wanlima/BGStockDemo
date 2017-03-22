//
//  BGStockConstant.h
//  BGStockDemo
//
//  Created by Passion on 2017/3/22.
//  Copyright © 2017年 pgadmin. All rights reserved.
//

#ifndef BGStockConstant_h
#define BGStockConstant_h


/***********************Colors*************************/

#define BGWhiteColor HEX(0XFFFFFF)

#define BGBlueColor  HEX(0x4990E2)

#define BGRedColor   HEX(0xD43A30)

#define BGGreenColor HEX(0x4CAF50)

#define BGMA5Color   HEX(0xF1B550)

#define BGMA10Color  HEX(0xDC4EFA)

#define BGMA20Color  HEX(0x509CF2)

#define BGDashColor  HEX(0x7F9976)

#define BGLineColor  HEX(0x28323D)

/***********************Colors*************************/




/***********************Frame*************************/

#define BGStockKLineRatio 0.6//k线图高度的比例

#define BGStockVolumeRatio 0.3//成交量图高度的比例

#define BGStockCandleMinWidth 6//蜡烛的最小宽度

#define BGStockCandleMaxWidth 20//蜡烛的最小宽度

#define BGStockCandleGap 1 //蜡烛的间隔

/***********************Frame*************************/





#define HEX(value)          [UIColor colorWithHex:value alpha:1.f]

#define HEX_A(value, alpha) [UIColor colorWithHex:value alpha:alpha]

#define WEAK_SELF __weak typeof(self)weakSelf = self

#endif /* BGStockConstant_h */
