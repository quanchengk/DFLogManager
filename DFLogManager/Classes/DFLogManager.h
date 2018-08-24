/*!
 @header DFLogManager.h
 @abstract 日志组件管理类
 @author Created by 全程恺 on 2018/1/26
 @version 0.1.3
 Copyright © 2018年 danfort. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DFLogModel.h"
#import "DFLogDBManager.h"

/*!
 @brief 定义当前程序的运行环境，不同环境对应各自的增删规则
 */
typedef NS_ENUM(NSInteger, DFLogType) {
    /*! 无日志模式，不记录日志，且设置后会清空所有已记录的日志，无悬浮球 */
    DFLogTypeNone,
    /*! 调试模式，日志条数无上限，默认显示悬浮球 */
    DFLogTypeDebug,
    /*! 生产模式，日志只保存就近的10条，悬浮球隐藏，后台记录，需要另外绑定隐藏事件弹出日志 */
    DFLogTypeRelease,
};

/*!
 @abstract 日志控件会影响控制器的状态栏样式，如果需要修改状态栏，请在日志控件不显示的场景下测试样式
 */
@interface DFLogManager : NSObject

/*!
 @abstract 定义当前程序的运行环境，不同环境对应各自的增删规则，参考DFLogType枚举
 */
@property (assign, nonatomic) DFLogType mode;

/*!
 @abstract 数据库操作对象，所有的增、删、改、查都在这个实例内完成
 */
@property (retain, nonatomic, readonly) DFLogDBManager *dbManager;

/*!
 @abstract 初始化方法，一个进程只需要一个日志管理类即可满足需求
 */
+ (instancetype)shareLogManager;

/*!
 @abstract 绑定指定的视图，通过隐藏事件来弹出日志
 @discussion 记录这个控件的点击次数，两次点击间隔需在during时间内，否则次数重置；如果满足条件的次数达到count，则触发日志弹出
 @param view 监听点击次数的对象，必传，且必须可交互
 @param duringTime 两次连击的容忍范围，如果设为0，则不重置
 @param count 必须大于0，否则没有意义，定义到达该次数，触发日志弹出
 
 @code
 [[DFLogManager shareLogManager] bindView:btn duringTime:2 targetCount:5];
 @endcode
 */
- (void)bindView:(UIView *)view duringTime:(NSInteger)duringTime targetCount:(NSInteger)count;

/*!
 @abstract 记录当前监听次数
 @discussion 在要求的时间内达到要求的次数，则触发日志弹出，和控件无关，交由
 @param <#参数说明，例如ratio 缩小的倍数...#>
 @result <#返回值类型#>
 @code <#示例代码#>
 */
/* 记录当前监听次数，在要求的时间内达到要求的次数，则触发日志弹出
 * duringTime：两次连击的容忍范围，如果设为0，则不重置
 * targetCount：必须大于0，否则没有意义，定义到达该次数，触发日志弹出
 */
- (void)recordCountDuringTime:(NSInteger)duringTime targetCount:(NSInteger)targetCount;

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

