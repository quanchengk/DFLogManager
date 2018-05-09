//
//  XDJDDLogManager.h
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFLogModel.h"
#import "DFLogDBManager.h"

typedef NS_ENUM(NSInteger, DFLogType) {
    DFLogTypeNone,      // 无日志模式，不记录日志，且设置后会清空所有已记录的日志，无悬浮球
    DFLogTypeDebug,     // 调试模式，日志条数无上限，会显示悬浮球
    DFLogTypeRelease,   // 生产模式，普通日志保留50条，异常日志保留20条，悬浮球隐藏，后台记录
};

/*
 * 日志控件会影响控制器的状态栏样式，如果需要修改状态栏，请在日志控件不显示的场景下测试样式
 */
@interface DFLogManager : NSObject

// 是否开启调试模式，如果传YES，则会在界面上出现日志按钮，可随时唤出调试页面
@property (assign, nonatomic) DFLogType mode;
// 数据库载体
@property (retain, nonatomic, readonly) DFLogDBManager *dbManager;

+ (instancetype)shareLogManager;

/* 绑定某个视图，记录这个控件的点击次数，两次点击要在during时间内，否则次数重置，如果在这个时间段内达到count次数，则触发日志弹出
 
 * view：监听点击次数的对象，必传，且必须可交互
 * duringTime：两次连击的容忍范围，如果设为0，则不重置
 * count：必须大于0，否则没有意义，定义到达该次数，触发日志弹出
 */
- (void)bindView:(UIView *)view duringTime:(NSInteger)duringTime targetCount:(NSInteger)count;

/* 设置顶部的输入内容，目前的用法是在顶部配置全局的base url，如果改变，通知全局切换接口环境，避免后台频繁要打包不同环境的应用程序
 * 只要调用了此方法，就提供文本输入框，不判断是否有content
 * content：当前的url地址
 * modifyBlock：修改后的回调
 */
- (void)textFieldContent:(NSString *)content modifyBlock:(void (^)(NSString *text))modifyBlock;

// 新增记录体
- (void)addLogModel:(DFLogModel *)logModel;

// 数据重置
- (void)reset;

@end

