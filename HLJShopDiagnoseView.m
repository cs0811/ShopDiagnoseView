//
//  HLJShopDiagnoseView.m
//  HLJ
//
//  Created by tongxuan on 16/8/29.
//  Copyright © 2016年 tongxuan. All rights reserved.
//

#import "HLJShopDiagnoseView.h"
#import "UIColor+HexColor.h"
//#import <QuartzCore/QuartzCore.h>

#define kScreenW    [UIScreen mainScreen].bounds.size.width
#define kM_PI(x)    x*M_PI/180

// 外侧圆弧到顶部标题的距离
#define kTopToTopTitleLabel     32.
// 外侧圆弧半径
#define kBaseProgressR      kScreenW*9/32.
// 多出的角度
#define kExtandAngle        10.

#define kAnimationTime      1.

@interface HLJShopDiagnoseView ()
{
    /**
     *  外圆弧上面的3个段位的中点
     */
    CGPoint _baseProgressMidPointBad;
    CGPoint _baseProgressMidPointMid;
    CGPoint _baseProgressMidPointGood;
    
    CGPoint _baseAreaMidPointBad;
    CGPoint _baseAreaMidPointMid;
    CGPoint _baseAreaMidPointGood;
    
    CGPoint _titleAreaMidPointBad;
    CGPoint _titleAreaMidPointMid;
    CGPoint _titleAreaMidPointGood;
    
    BOOL _shouldLayout;
    BOOL _shouldEndWaiting;
    ShopDiagnoseType _endWaitingType;
    
    ShopDiagnoseType _currentType;
}
@property (nonatomic, strong) UILabel * topTitleLabel;
@property (nonatomic, strong) UILabel * resultTitleLabel;

@property (nonatomic, strong) CAShapeLayer * baseProgressLayer;
@property (nonatomic, strong) CAShapeLayer * resultProgressLayer;
@property (nonatomic, strong) UIImageView * resultProgressImg;

@property (nonatomic, strong) CAShapeLayer * baseAreaLayer;
@property (nonatomic, strong) UIImageView * resultAreaImg;

@property (nonatomic, strong) UILabel * badLabel;
@property (nonatomic, strong) UILabel * midLabel;
@property (nonatomic, strong) UILabel * goodLabel;

@property (nonatomic, strong) UIButton * doBtn;
@end

@implementation HLJShopDiagnoseView

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentType = ShopDiagnoseTypeUnDo;
        _shouldLayout = YES;
        [self loadUI];
        [self scrollToType:_currentType waitingDiagnose:NO withAnimation:NO];
    }
    return  self;
}

- (void)setInitType:(ShopDiagnoseType)initType {
    _currentType = initType;
    [self scrollToType:_currentType waitingDiagnose:NO withAnimation:NO];
}

#pragma mark loadUI
- (void)loadUI {
    
    self.backgroundColor = [UIColor colorWithHexString:@"ff5454"];
    
    // 基本计算
    [self customCalculate];
    
    [self addSubview:self.topTitleLabel];
    [self addSubview:self.resultTitleLabel];
    [self.layer addSublayer:self.baseProgressLayer];
    [self.layer addSublayer:self.resultProgressLayer];
    [self addSubview:self.resultProgressImg];
    [self.layer addSublayer:self.baseAreaLayer];
    [self addSubview:self.resultAreaImg];
    [self addSubview:self.badLabel];
    [self addSubview:self.midLabel];
    [self addSubview:self.goodLabel];
    [self addSubview:self.doBtn];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_shouldLayout) {
        return;
    }
    
    NSString * topTitle = @"";
    NSString * resultTitle = @"";
    NSString * btnTitle = @"";
    
    if (_currentType == ShopDiagnoseTypeUnDo) {
        topTitle = @"抱歉！您目前还未诊断过店铺";
        resultTitle = @"尚未诊断";
        btnTitle = @"立即检测";
    }else if (_currentType == ShopDiagnoseTypeBad) {
        topTitle = @"店铺已存在严重问题影响日常经营";
        resultTitle = @"店铺差劲";
        btnTitle = @"重新检测";
    }else if (_currentType == ShopDiagnoseTypeMid) {
        topTitle = @"您的店铺还有很大提升空间";
        resultTitle = @"店铺良好";
        btnTitle = @"重新检测";
    }else if (_currentType == ShopDiagnoseTypeGood) {
        topTitle = @"恭喜！您的店铺为优质店铺";
        resultTitle = @"店铺优秀";
        btnTitle = @"重新检测";
    }
    
    self.topTitleLabel.text = topTitle;
    self.resultTitleLabel.text = resultTitle;
    [self.doBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    self.frame = CGRectMake(0, 0, kScreenW, CGRectGetMaxY(self.doBtn.frame)+36);
}

- (void)scrollToType:(ShopDiagnoseType)type waitingDiagnose:(BOOL)waiting withAnimation:(BOOL)animation {
    _shouldLayout = NO;
    CGFloat item = kM_PI((180+kExtandAngle*2)/3);

    UIBezierPath * progressLayerPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kScreenW/2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR) radius:kBaseProgressR startAngle:kM_PI(180)-kM_PI(kExtandAngle) endAngle:-item/2+kM_PI(kExtandAngle) clockwise:YES];
    
    self.resultProgressLayer.path = progressLayerPath.CGPath;
    self.resultAreaImg.transform = CGAffineTransformRotate(self.resultAreaImg.transform, -item);
    
    NSTimeInterval time = kAnimationTime;
    if (!animation || _currentType == type) {
        time = 0;
    }
    
    CGFloat progressFromValue = 0;
    CGFloat progressToValue = 1;
    CGFloat areaRotationToValue = -item;
    CGFloat resultAreaEndAngle = -item/2+kM_PI(kExtandAngle);
    CGFloat resultAreaStartAngle = kM_PI(180)+item/2-kM_PI(kExtandAngle);
    BOOL clockwise = YES;
    
    if (type == ShopDiagnoseTypeBad) {
        if (_currentType == ShopDiagnoseTypeBad) {
            progressFromValue = !animation?0:0.2;
            resultAreaEndAngle = -item/2+kM_PI(kExtandAngle)-item*1.99;
            resultAreaStartAngle = !animation?kM_PI(180)-kM_PI(kExtandAngle):resultAreaEndAngle;
            clockwise = YES;
        }else if (_currentType == ShopDiagnoseTypeMid || _currentType == ShopDiagnoseTypeUnDo) {
            progressFromValue = 0.6;
            resultAreaEndAngle = kM_PI(180)+item/2-kM_PI(kExtandAngle);
            resultAreaStartAngle = -item/2+kM_PI(kExtandAngle)-item*1;
            clockwise = NO;
            time = time/2.;
        }else if (_currentType == ShopDiagnoseTypeGood) {
            progressFromValue = 1;
            resultAreaEndAngle = kM_PI(180)+item/2-kM_PI(kExtandAngle);
            resultAreaStartAngle = -item/2+kM_PI(kExtandAngle);
            clockwise = NO;
        }
        progressToValue = 0.2;
        areaRotationToValue = -item;
        
    }else if (type == ShopDiagnoseTypeMid || type == ShopDiagnoseTypeUnDo) {
        if (_currentType == ShopDiagnoseTypeBad) {
            progressFromValue = 0.2;
            resultAreaEndAngle = -item/2+kM_PI(kExtandAngle)-item*1;
            resultAreaStartAngle = kM_PI(180)+item/2-kM_PI(kExtandAngle);
            clockwise = YES;
            time = time/2.;
        }else if (_currentType == ShopDiagnoseTypeMid || _currentType == ShopDiagnoseTypeUnDo) {
            progressFromValue = !animation?0:0.6;
            resultAreaEndAngle = -item/2+kM_PI(kExtandAngle)-item*1;
            resultAreaStartAngle = !animation?kM_PI(180)-kM_PI(kExtandAngle):resultAreaEndAngle;
            clockwise = YES;
        }else if (_currentType == ShopDiagnoseTypeGood) {
            progressFromValue = 1;
            resultAreaEndAngle = kM_PI(180)+item/2-kM_PI(kExtandAngle)+item*1;
            resultAreaStartAngle = -item/2+kM_PI(kExtandAngle);
            clockwise = NO;
            time = time/2.;
        }
        progressToValue = 0.6;
        areaRotationToValue = 0;
    }else if (type == ShopDiagnoseTypeGood) {
        if (_currentType == ShopDiagnoseTypeBad) {
            progressFromValue = 0.2;
            resultAreaEndAngle = -item/2+kM_PI(kExtandAngle);
            resultAreaStartAngle = kM_PI(180)+item/2-kM_PI(kExtandAngle);
            clockwise = YES;
        }else if (_currentType == ShopDiagnoseTypeMid || _currentType == ShopDiagnoseTypeUnDo) {
            progressFromValue = 0.6;
            resultAreaEndAngle = -item/2+kM_PI(kExtandAngle);
            resultAreaStartAngle = kM_PI(180)+item/2-kM_PI(kExtandAngle)+item*1;
            clockwise = YES;
            time = time/2.;
        }else if (_currentType == ShopDiagnoseTypeGood) {
            progressFromValue = !animation?0:1;
            resultAreaEndAngle = -item/2+kM_PI(kExtandAngle);
            resultAreaStartAngle = !animation?kM_PI(180)-kM_PI(kExtandAngle):resultAreaEndAngle;
            clockwise = YES;
        }
        progressToValue = 1;
        areaRotationToValue = item;
    }
    
    UIBezierPath * path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kScreenW/2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR) radius:kBaseProgressR-10 startAngle:resultAreaStartAngle endAngle:resultAreaEndAngle clockwise:clockwise];
    
    UIBezierPath * path1Temp = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kScreenW/2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR) radius:kBaseProgressR startAngle:resultAreaStartAngle endAngle:resultAreaEndAngle clockwise:clockwise];
    
    // 圆点转圈
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = time;
    pathAnimation.path = path1Temp.CGPath;
    [self.resultProgressImg.layer addAnimation:pathAnimation forKey:nil];
    
    // 进度条
    CABasicAnimation *pathAnimation1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation1.duration = time;
    pathAnimation1.fromValue = [NSNumber numberWithFloat:progressFromValue];
    pathAnimation1.toValue = [NSNumber numberWithFloat:progressToValue];
    pathAnimation1.removedOnCompletion = NO;
    pathAnimation1.fillMode = kCAFillModeForwards;
    [self.resultProgressLayer addAnimation:pathAnimation1 forKey:nil];
    
    // 三角形转圈
    CAKeyframeAnimation *pathAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation2.calculationMode = kCAAnimationPaced;
    pathAnimation2.fillMode = kCAFillModeForwards;
    pathAnimation2.removedOnCompletion = NO;
    pathAnimation2.duration = time;
    pathAnimation2.path = path2.CGPath;
    [self.resultAreaImg.layer addAnimation:pathAnimation2 forKey:nil];
    
    // 三角形旋转
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:areaRotationToValue];
    rotationAnimation.duration = time;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.resultAreaImg.layer addAnimation:rotationAnimation forKey:nil];
    
    _currentType = type;
    
    if (!waiting) {
        NSString * colorStr = @"ff5454";
        if (type == ShopDiagnoseTypeBad || ShopDiagnoseTypeUnDo) {
            colorStr = @"ff5454";
        }else if (type == ShopDiagnoseTypeMid) {
            colorStr = @"ffa031";
        }else if (type == ShopDiagnoseTypeGood) {
            colorStr = @"30c12a";
        }
        [UIView animateWithDuration:time animations:^{
            self.backgroundColor = [UIColor colorWithHexString:colorStr];
            [self.doBtn setTitleColor:[UIColor colorWithHexString:colorStr] forState:UIControlStateNormal];
            self.doBtn.titleLabel.textColor = [UIColor colorWithHexString:colorStr];
        }];
        if (self.chageNavgationBarColor) {
            self.chageNavgationBarColor(colorStr,time);
        }
        
        _shouldEndWaiting = NO;
        [self performSelector:@selector(enableDoBtn) withObject:nil afterDelay:time];
    }else {
        [self performSelector:@selector(waitingShopDiagnose) withObject:nil afterDelay:time];
    }
}

- (void)endShopDiagnoseWithType:(ShopDiagnoseType)type {
    _endWaitingType = type;
    _shouldEndWaiting = YES;
}

#pragma mark action 
- (void)startDiagnose {
    if (self.startShopDiagnose) {
        self.startShopDiagnose();
    }
    self.doBtn.hidden = YES;
    self.topTitleLabel.text = @"正在检测店铺状态";
    self.resultTitleLabel.text = @"诊断中";
    _shouldEndWaiting = NO;
    [self waitingShopDiagnose];
}
- (void)enableDoBtn {
    self.doBtn.hidden = NO;
    _shouldLayout = YES;
    [self setNeedsLayout];
}

- (void)waitingShopDiagnose {
    ShopDiagnoseType type ;
    if (_currentType == ShopDiagnoseTypeBad) {
        type = ShopDiagnoseTypeGood;
    }else {
        type = ShopDiagnoseTypeBad;
    }
    
    if (_shouldEndWaiting) {
        type = _endWaitingType;
    }
    
    [self scrollToType:type waitingDiagnose:!_shouldEndWaiting withAnimation:YES];
}

#pragma mark 
- (void)customCalculate {
    // 每一个区间所对应的弧度
    CGFloat item = kM_PI((180+kExtandAngle*2)/3);
    CGFloat tempX = cos(item/2-kM_PI(kExtandAngle))*kBaseProgressR;
    CGFloat tempy = sin(item/2-kM_PI(kExtandAngle))*kBaseProgressR;
    _baseProgressMidPointBad = CGPointMake(kScreenW/2-tempX, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy);
    _baseProgressMidPointMid = CGPointMake(kScreenW/2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel);
    _baseProgressMidPointGood = CGPointMake(kScreenW/2+tempX, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy);
    
    CGFloat tempX1 = cos(item/2-kM_PI(kExtandAngle))*(kBaseProgressR-10);
    CGFloat tempy1 = sin(item/2-kM_PI(kExtandAngle))*(kBaseProgressR-10);
    _baseAreaMidPointBad = CGPointMake(kScreenW/2-tempX1, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy1);
    _baseAreaMidPointMid = CGPointMake(kScreenW/2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+10);
    _baseAreaMidPointGood = CGPointMake(kScreenW/2+tempX1, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy1);
    
    CGFloat tempX2 = cos(item/2-kM_PI(kExtandAngle))*(kBaseProgressR-25);
    CGFloat tempy2 = sin(item/2-kM_PI(kExtandAngle))*(kBaseProgressR-25);
    _titleAreaMidPointBad = CGPointMake(kScreenW/2-tempX2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy2);
    _titleAreaMidPointMid = CGPointMake(kScreenW/2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+25);
    _titleAreaMidPointGood = CGPointMake(kScreenW/2+tempX2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy2);
    
}

- (void)dealloc {
}

#pragma mark getter
- (UILabel *)topTitleLabel {
    if (!_topTitleLabel) {
        _topTitleLabel = [UILabel new];
        _topTitleLabel.textColor = [UIColor whiteColor];
        _topTitleLabel.alpha = 0.6;
        _topTitleLabel.font = [UIFont systemFontOfSize:14.];
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
        _topTitleLabel.frame = CGRectMake(12, 25, kScreenW-24, 30);
        _topTitleLabel.text = @"正在检测店铺状态";
    }
    return _topTitleLabel;
}
- (UILabel *)resultTitleLabel {
    if (!_resultTitleLabel) {
        _resultTitleLabel = [UILabel new];
        _resultTitleLabel.textColor = [UIColor whiteColor];
        _resultTitleLabel.font = [UIFont systemFontOfSize:22.];
        _resultTitleLabel.textAlignment = NSTextAlignmentCenter;
        _resultTitleLabel.frame = CGRectMake(0, 0, 100, 30);
        _resultTitleLabel.center = CGPointMake(kScreenW/2, CGRectGetMaxY(self.midLabel.frame)+30);
        _resultTitleLabel.text = @"诊断中";
    }
    return _resultTitleLabel;
}
- (CAShapeLayer *)baseProgressLayer {
    if (!_baseProgressLayer) {
        _baseProgressLayer = [CAShapeLayer layer];
        
        UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kScreenW/2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR) radius:kBaseProgressR startAngle:kM_PI(180)-kM_PI(kExtandAngle) endAngle:kM_PI(kExtandAngle) clockwise:YES];
        _baseProgressLayer.path = path.CGPath;
        _baseProgressLayer.fillColor = [UIColor clearColor].CGColor;
        _baseProgressLayer.lineCap = kCALineCapRound;
        _baseProgressLayer.strokeColor = RGBACOLOR(255, 255, 255, 0.15).CGColor;
        _baseProgressLayer.lineWidth = 2;
    }
    return _baseProgressLayer;
}
- (CAShapeLayer *)resultProgressLayer {
    if (!_resultProgressLayer) {
        _resultProgressLayer = [CAShapeLayer layer];
        _resultProgressLayer.fillColor = [UIColor clearColor].CGColor;
        _resultProgressLayer.lineCap = kCALineCapRound;
        _resultProgressLayer.strokeColor = RGBACOLOR(255, 255, 255, 0.5).CGColor;
        _resultProgressLayer.lineWidth = 2;
    }
    return _resultProgressLayer;
}
- (UIImageView *)resultProgressImg {
    if (!_resultProgressImg) {
        _resultProgressImg = [UIImageView new];
        _resultProgressImg.frame = CGRectMake(0, 0, 7, 7);
        _resultProgressImg.center = _baseProgressMidPointBad;
        _resultProgressImg.image = [UIImage imageNamed:@"shopDiagnose_progressSpot"];
    }
    return _resultProgressImg;
}
- (CAShapeLayer *)baseAreaLayer {
    if (!_baseAreaLayer) {
        _baseAreaLayer = [CAShapeLayer layer];
        
        UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kScreenW/2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR) radius:kBaseProgressR-10 startAngle:kM_PI(180)-kM_PI(kExtandAngle) endAngle:kM_PI(kExtandAngle) clockwise:YES];
        _baseAreaLayer.path = path.CGPath;
        _baseAreaLayer.fillColor = [UIColor clearColor].CGColor;
        _baseAreaLayer.strokeColor = RGBACOLOR(255, 255, 255, 0.2).CGColor;
        _baseAreaLayer.lineWidth = 7;
        
        CGFloat item = kM_PI((180+kExtandAngle*2)/3);
        CGFloat tempX1 = cos(item-kM_PI(kExtandAngle))*(kBaseProgressR-10.-_baseAreaLayer.lineWidth/2+1);
        CGFloat tempX2 = cos(item-kM_PI(kExtandAngle))*(kBaseProgressR-10.+_baseAreaLayer.lineWidth/2-1);
        CGFloat tempy1 = sin(item-kM_PI(kExtandAngle))*(kBaseProgressR-10.-_baseAreaLayer.lineWidth/2+1);
        CGFloat tempy2 = sin(item-kM_PI(kExtandAngle))*(kBaseProgressR-10.+_baseAreaLayer.lineWidth/2-1);
        CGPoint leftPoint1 = CGPointMake(kScreenW/2-tempX1, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy1);
        CGPoint leftPoint2 = CGPointMake(kScreenW/2-tempX2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy2);
        CGPoint rightPoint1 = CGPointMake(kScreenW/2+tempX1, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy1);
        CGPoint rightPoint2 = CGPointMake(kScreenW/2+tempX2, CGRectGetMaxY(self.topTitleLabel.frame)+kTopToTopTitleLabel+kBaseProgressR-tempy2);
        
        CAShapeLayer * leftLayer = [CAShapeLayer layer];
        UIBezierPath * path1 = [UIBezierPath bezierPath];
        [path1 moveToPoint:leftPoint1];
        [path1 addLineToPoint:leftPoint2];
        leftLayer.path = path1.CGPath;
        leftLayer.fillColor = [UIColor clearColor].CGColor;
        leftLayer.strokeColor = RGBACOLOR(255, 255, 255, 0.3).CGColor;
        leftLayer.lineCap = kCALineCapRound;
        leftLayer.lineWidth = 1;
        [_baseAreaLayer addSublayer:leftLayer];
        
        CAShapeLayer * rightLayer = [CAShapeLayer layer];
        UIBezierPath * path2 = [UIBezierPath bezierPath];
        [path2 moveToPoint:rightPoint1];
        [path2 addLineToPoint:rightPoint2];
        rightLayer.path = path2.CGPath;
        rightLayer.fillColor = [UIColor clearColor].CGColor;
        rightLayer.strokeColor = RGBACOLOR(255, 255, 255, 0.3).CGColor;
        rightLayer.lineCap = kCALineCapRound;
        rightLayer.lineWidth = 1;
        [_baseAreaLayer addSublayer:rightLayer];
    }
    return _baseAreaLayer;
}

- (UIImageView *)resultAreaImg {
    if (!_resultAreaImg) {
        _resultAreaImg = [UIImageView new];
        _resultAreaImg.frame = CGRectMake(0,0, 8, 10);
        _resultAreaImg.center = _baseAreaMidPointBad;
        _resultAreaImg.image = [UIImage imageNamed:@"shopDiagnose_areaTarget"];
    }
    return _resultAreaImg;
}
- (UILabel *)badLabel {
    if (!_badLabel) {
        _badLabel = [UILabel new];
        _badLabel.text = @"差劲";
        _badLabel.textColor = [UIColor whiteColor];
        _badLabel.font = [UIFont systemFontOfSize:9.];
        _badLabel.alpha = 0.4;
        _badLabel.textAlignment = NSTextAlignmentCenter;
        _badLabel.frame = CGRectMake(0, 0, 50, 20);
        _badLabel.center = _titleAreaMidPointBad;
        
        CGFloat item = kM_PI((180+kExtandAngle*2)/3);
        _badLabel.transform = CGAffineTransformRotate(_badLabel.transform, -item);
    }
    return _badLabel;
}
- (UILabel *)midLabel {
    if (!_midLabel) {
        _midLabel = [UILabel new];
        _midLabel.text = @"良好";
        _midLabel.textColor = [UIColor whiteColor];
        _midLabel.alpha = 0.4;
        _midLabel.font = [UIFont systemFontOfSize:9.];
        _midLabel.textAlignment = NSTextAlignmentCenter;
        _midLabel.frame = CGRectMake(0, 0, 50, 20);
        _midLabel.center = _titleAreaMidPointMid;
    }
    return _midLabel;
}
- (UILabel *)goodLabel {
    if (!_goodLabel) {
        _goodLabel = [UILabel new];
        _goodLabel.text = @"优秀";
        _goodLabel.textColor = [UIColor whiteColor];
        _goodLabel.alpha = 0.4;
        _goodLabel.font = [UIFont systemFontOfSize:9.];
        _goodLabel.textAlignment = NSTextAlignmentCenter;
        _goodLabel.frame = CGRectMake(0, 0, 50, 20);
        _goodLabel.center = _titleAreaMidPointGood;
        
        CGFloat item = kM_PI((180+kExtandAngle*2)/3);
        _goodLabel.transform = CGAffineTransformRotate(_goodLabel.transform, item);
    }
    return _goodLabel;
}
- (UIButton *)doBtn {
    if (!_doBtn) {
        _doBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_doBtn setTitle:@"立即检测" forState:UIControlStateNormal];
        [_doBtn setTitleColor:[UIColor colorWithHexString:@"ff5454"] forState:UIControlStateNormal];
        [_doBtn setBackgroundImage:[UIImage imageNamed:@"shopDiagnose_submitBtn"] forState:UIControlStateNormal];
        _doBtn.frame = CGRectMake(0, 0, 100, 36);
        _doBtn.backgroundColor = RGBACOLOR(255, 255, 255, 0.96);
//        _doBtn.layer.shadowColor = kColorBack1.CGColor;
//        _doBtn.layer.shadowOffset = CGSizeMake(1, 1);
//        _doBtn.layer.shadowOpacity = 0.8;
//        _doBtn.layer.shadowRadius = 18;
        _doBtn.layer.cornerRadius = 18;
        _doBtn.center = CGPointMake(kScreenW/2, CGRectGetMaxY(self.resultTitleLabel.frame)+20+10);
        _doBtn.titleLabel.font = [UIFont systemFontOfSize:14.];
        
        [_doBtn addTarget:self action:@selector(startDiagnose) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doBtn;
}

@end
