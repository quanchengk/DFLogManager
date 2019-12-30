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
 @abstract 日志控件会影响控制器的状态栏样式（固定为透明底、黑字，并且无法修改）。如果需要修改状态栏，请在日志悬浮球隐藏的场景下使用
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
@abstract 权限口令，如果有值，则弹框要求输入与此对饮的口令，才可显示面板
*/
@property (nonatomic, strong) NSString *adminPsw;

/*!
 @abstract 初始化方法，一个进程只需要一个日志管理类即可满足需求
 */
+ (instancetype)shareLogManager;

/*!
 @abstract 绑定指定控件，通过绑定事件来弹出日志
 @discussion 记录这个控件的点击次数，两次点击间隔需在duringTime时间内，否则次数重置；如果满足条件的次数达到count，触发日志弹出
 @param view 监听点击次数的对象，必传。控件必须可交互
 @param duringTime 两次连击的容忍范围，如果设为0，则不重置
 @param count 必须大于0，否则没有意义，定义到达该次数，触发日志弹出
 
 @code
 [[DFLogManager shareLogManager] bindView:btn duringTime:2 targetCount:5];
 @endcode
 */
- (void)bindView:(UIView *)view duringTime:(CGFloat)duringTime targetCount:(NSInteger)count;

/*!
 @abstract 记录当前监听次数
 @discussion 在指定的时间范围内达到要求的次数，则触发日志弹出，和具体哪个控件触发无关，交由项目自己触发
 @param duringTime 两次连击的容忍范围，如果大于0，那么两两触发的时间必须在在duringTime（秒）时间内，超过这个范围则从头计数；设为0，则没有时间范围的概念，不重置。
 @param targetCount 要求达到的触发次数，建议每次触发传的值相同，否则以最后一次传的数据为比较标准。触发次数达到该次数，触发日志弹出
 */
- (void)recordCountDuringTime:(CGFloat)duringTime targetCount:(NSInteger)targetCount;

/*!
 @abstract 设置顶部的输入内容
 @discussion 目前的用法是在顶部配置全局的base url使用，输入结束后，如果改变，通知全局切换接口环境，避免后台因切换环境的频繁打包
 @param content 当前的文本内容
 @param modifyBlock 确认修改的行为回调，可在方法内保存最新文本内容
 */
- (void)textFieldContent:(NSString *)content modifyBlock:(void (^)(NSString *text))modifyBlock;

/*!
 @abstract 新增日志对象
 @discussion 数据库做插入、覆盖行为
 @param logModel 日志对象
 
 @code
 
 DFLogModel *logModel = [DFLogModel new];
 logModel.selector = @"测试测试测试测试测试";
 logModel.requestObject = @"请求方法";
 logModel.responseObject = @"回参";
 logModel.error = arc4random() % 2 ? @"错误" : @"";
 [[DFLogManager shareLogManager] addLogModel:logModel];
 @endcode
 */
- (void)addLogModel:(DFLogModel *)logModel;

/*!
 @abstract 日志数据清空
 */
- (void)reset;

@end

