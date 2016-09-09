//
//  HLJShopDiagnoseView.h
//  HLJTest
//
//  Created by tongxuan on 16/8/29.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ShopDiagnoseType) {
    ShopDiagnoseTypeUnDo   = 0,         // 还未检测
    ShopDiagnoseTypeBad ,               // 差劲
    ShopDiagnoseTypeMid ,               // 良好
    ShopDiagnoseTypeGood ,              // 优秀
};

@interface HLJShopDiagnoseView : UIView
// 初始类型 （默认为 UnDo ）
@property (nonatomic, assign) ShopDiagnoseType initType;
@property (nonatomic, copy) void(^chageNavgationBarColor)(NSString * colorStr, CGFloat time);
// 开始检测
@property (nonatomic, copy) void(^startShopDiagnose)();

- (void)endShopDiagnoseWithType:(ShopDiagnoseType)type;

@end
