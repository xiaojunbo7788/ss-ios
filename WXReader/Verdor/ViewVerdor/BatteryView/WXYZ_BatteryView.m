//
//  DPBatteryView.m
//  WXReader
//
//  Created by Andrew on 2018/6/10.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#import "WXYZ_BatteryView.h"

typedef enum : NSUInteger {
    WXBatteryStateColorNormal,
    WXBatteryStateColorCharging,
    WXBatteryStateColorWarning,
} WXBatteryStateColor;

@interface WXYZ_BatteryView ()
{
    UIView *batteryView;
    UILabel *batteryLabel;
    CAShapeLayer *batteryLayer;
    CAShapeLayer *layer2;
    
    CGFloat w;
    CGFloat lineW;
    NSTimer *time;
}

@end

@implementation WXYZ_BatteryView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
        [self createSubViews];
        [self batteryLevelChanged];
        [self updateTime];
    }
    return self;
}

- (void)initialize
{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIDeviceBatteryLevelDidChangeNotification
     object:nil queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *notification) {
         [weakSelf batteryLevelChanged];
     }];
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIDeviceBatteryStateDidChangeNotification
     object:nil queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *notification) {
         [weakSelf batteryStateChanged];
     }];
}

- (void)createSubViews
{
    //电池的宽度
    w = 25;
    //电池的x的坐标
    CGFloat x = 0;
    //电池的y的坐标
    CGFloat y = self.height / 2  - 5;
    //电池的线宽
    lineW = 1;
    //电池的高度
    CGFloat h = 10;
    
    //画电池
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w, h) cornerRadius:2];
    batteryLayer = [CAShapeLayer layer];
    batteryLayer.lineWidth = lineW;
    batteryLayer.strokeColor = [UIColor grayColor].CGColor;
    batteryLayer.fillColor = [UIColor clearColor].CGColor;
    batteryLayer.path = [path1 CGPath];
    [self.layer addSublayer:batteryLayer];
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(x+w+1, y+h/3)];
    [path2 addLineToPoint:CGPointMake(x+w+1, y+h*2/3)];
    layer2 = [CAShapeLayer layer];
    layer2.lineWidth = 2;
    layer2.strokeColor = [UIColor grayColor].CGColor;
    layer2.fillColor = [UIColor clearColor].CGColor;
    layer2.path = [path2 CGPath];
    [self.layer addSublayer:layer2];
    
    //绘制进度
    batteryView = [[UIView alloc] initWithFrame:CGRectMake(x + 1,y + lineW, 0, h - lineW * 2)];
    batteryView.layer.cornerRadius = 1;
    [self addSubview:batteryView];
    
    batteryLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + w + 5, y, 80, h)];
    batteryLabel.textColor = [UIColor grayColor];
    batteryLabel.textAlignment = NSTextAlignmentLeft;
    batteryLabel.font = kFont10;
    [self addSubview:batteryLabel];
    
    time = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)updateTime
{
    //获取当前时间
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    
    if (hour < 10 && minute < 10) {
        batteryLabel.text = [NSString stringWithFormat:@"0%d:0%d",(int)hour, (int)minute];
    } else if (hour < 10) {
        batteryLabel.text = [NSString stringWithFormat:@"0%d:%d",(int)hour, (int)minute];
    } else if (minute < 10) {
        batteryLabel.text = [NSString stringWithFormat:@"%d:0%d",(int)hour, (int)minute];
    } else {
        batteryLabel.text = [NSString stringWithFormat:@"%d:%d",(int)hour, (int)minute];
    }
    
}

// 电池剩余比例
- (void)batteryLevelChanged
{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    
    float batteryLevel = [device batteryLevel] * 100;
    
    if (batteryLevel < 0) {
        batteryLevel = 0;
    } else if (batteryLevel > 100){
        batteryLevel = 100;
    }
    
    if (batteryLevel <= 10) {
        [self changeBatteryState:WXBatteryStateColorWarning];
    } else {
        [self changeBatteryState:WXBatteryStateColorNormal];
    }
    
    CGRect frame = batteryView.frame;
    frame.size.width = (batteryLevel * (w - lineW * 2)) / 100;
    batteryView.frame  = frame;
}

- (void)batteryStateChanged
{
    switch ([[UIDevice currentDevice] batteryState]) {
        case 0: // 未开启监视电池状态
            [self changeBatteryState:WXBatteryStateColorNormal];
            break;
        case 1: // 电池未充电状态
            [self changeBatteryState:WXBatteryStateColorNormal];
            break;
        case 2: // 电池充电状态
            [self changeBatteryState:WXBatteryStateColorCharging];
            break;
        case 3: // 电池充电完成
            [self changeBatteryState:WXBatteryStateColorCharging];
            break;
            
        default:
            break;
    }
}

- (void)changeBatteryState:(WXBatteryStateColor)batteryState
{
    switch (batteryState) {
        case WXBatteryStateColorNormal:
            batteryView.backgroundColor = kColorRGBA(131, 131, 131, 1);
            break;
        case WXBatteryStateColorCharging:
            batteryView.backgroundColor = kColorRGBA(75, 216, 102, 1);
            break;
        case WXBatteryStateColorWarning:
            batteryView.backgroundColor = kColorRGBA(252, 62, 46, 1);
            break;
            
        default:
            break;
    }
}

- (void)setBatteryTintColor:(UIColor *)batteryTintColor
{
    batteryLayer.strokeColor = batteryTintColor.CGColor;
    layer2.strokeColor = batteryTintColor.CGColor;
    batteryLabel.textColor = batteryTintColor;
    
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging || [UIDevice currentDevice].batteryState == UIDeviceBatteryStateFull) {
        [self changeBatteryState:WXBatteryStateColorCharging];
    }
}

- (void)dealloc
{
    [time invalidate];
    time = nil;
}

@end
