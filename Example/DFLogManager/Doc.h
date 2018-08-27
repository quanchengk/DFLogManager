/*!
 @header DFLog
 @abstract 日志组件，提供日志的记录、展示、内容管理等组件
 @author Created by 全程恺 on 2018/1/26
 @version 0.1.3
 Copyright © 2018年 danfort. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DFLogModel.h"
#import "DFLogDBManager.h"
#import "DFLogModel.h"
#import <UIKit/UIKit.h>
#import <MJExtension/MJExtension.h>

/*!
 @abstract 提供悬浮球样式，默认显示在屏幕左边垂直居中的位置，可随意拖动，松手后找最近的屏幕边吸附，点击后弹出日志列表，再次点击收起弹框
 */
@interface DFLogCircleView : UIWindow

/*!
 @abstract 弹出悬浮球
 @discussion 自带点击事件，只要告诉控件什么时候该显示即可
 @code
 
 DFLogCircleView *circleView = [[DFLogCircleView alloc] initWithFrame:CGRectZero];
 [circleView show];
 @endcode
 */
- (void)show;

@end

/*!
 @abstract 日志数据库操作类，包括日志的增、删、改、查
 */
@interface DFLogDBManager : NSObject

/*!
 @abstract 最大可保存的日志条数，超出此条数的旧数据会自动删去
 */
@property (assign, nonatomic) NSInteger maxLogerCount;

/*!
 @abstract 获取指定范围内的日志对象数组
 @param fromIndex 按时间顺序从近到远的顺序，获取范围的起始下标，如果越界，会返回nil
 @param toIndex 按时间顺序从近到远的顺序，获取范围的终止下标，如果越界，会自动筛选到日志的最后一条
 @result 日志对象数组
 @code
 
 NSArray<DFLogModel *> *items = [[DFLogManager shareLogManager].dbManager getModelFrom:_items.count to:pageSize];
 @endcode
 */
- (NSArray<DFLogModel *> *)getModelFrom:(NSInteger)fromIndex to:(NSInteger)toIndex;

/*!
 @abstract 获取数据库里面保存的日志数
 @result NSInteger 已保存的日志数
 */
- (NSInteger)maxCountFromDB;

/*!
 @abstract 保存日志对象
 @discussion 如果logModel包含requestID属性且值大于0，查找数据库内id相同的日志，做覆盖操作；如果没有requestID或值为0，查找数据库内最大id，递增1并记录在数据库中
 @param logModel 日志对象，详情查看DFLogModel类定义的属性
 @result BOOL 返回保存的结果
 */
- (BOOL)saveModel:(DFLogModel *)logModel;

/*!
 @abstract 删除指定的日志对象
 @discussion 如果logModel没有requestID或值为0，删除失败；如果数据库内查找不到指定的requestID，删除失败；其余条件删除成功
 @param logModel 日志对象，详情查看DFLogModel类定义的属性
 @result BOOL 返回删除的结果
 */
- (BOOL)deleteModel:(DFLogModel *)logModel;

/*!
 @abstract 批量删除日志对象
 @discussion 先调用方法getModelFrom:to:再针对找到的数据数组批量做删除操作
 */
- (void)deleteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
/*!
 @abstract 清空所有日志对象
 @result BOOL 返回删除的结果
 */
- (BOOL)deleteAllModel;

@end

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
 @discussion 在指定的时间范围内达到要求的次数，则触发日志弹出，和具体哪个控件触发无关，交由项目自己触发
 @param duringTime 两次连击的容忍范围，如果大于0，那么两两触发的时间必须在在duringTime（秒）时间内，超过这个范围则重头计数；设为0，则没有时间范围的概念，不重置。
 @param targetCount 要求达到的触发次数，建议每次触发传的值相同，否则以最后一次传的数据为比较标准。触发次数达到该次数，触发日志弹出
 */
- (void)recordCountDuringTime:(NSInteger)duringTime targetCount:(NSInteger)targetCount;

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

/*!
 @abstract 日志对象的数据结构
 */
@interface DFLogModel : NSObject

/*!
 @abstract 当前日志的唯一id，新内容递增1
 */
@property (nonatomic, retain) NSNumber *requestID;

/*!
 @abstract 日志的方法名，目前保存的是请求地址
 */
@property (nonatomic, copy) NSString *selector;

/*!
 @abstract 日志的错误原因，目前保存的是服务回参的错误详情
 */
@property (nonatomic, copy) NSString *error;

/*!
 @abstract 日志的调用参数，目前保存的是api入参字典
 */
@property (nonatomic, copy) NSString *requestObject;

/*!
 @abstract 日志的应答参数，目前保存的是api回参内容
 */
@property (nonatomic, copy) NSString *responseObject;

/*!
 @abstract 日志的保存时间
 */
@property (nonatomic, retain) NSDate *occurTime;

/*!
 @abstract cell用到的属性，区分当前数据是否已被选中
 */
@property (assign, nonatomic) BOOL selected;
/*!
 @abstract cell用到的属性，展示在文本区的内容，以换行符切割的数据内容
 */
@property (retain, nonatomic) NSArray *contentSeperateArr;
@end

@class DFLogerTableViewHeader;
/*!
 @abstract 日志展示视图tableview选中事件的代理声明
 */
@protocol DFLogerDelegate <NSObject>

/*!
 @abstract 选中头部的代理通知
 */
- (void)selectHeaderViewAt:(DFLogerTableViewHeader *)header;
/*!
 @abstract 取消选中头部的代理通知
 */
- (void)deselectHeaderViewAt:(DFLogerTableViewHeader *)header;

@end

/*!
 @abstract 日志展示视图的列表本体
 */
@class DFLogModel;
@interface DFLogTableView : UITableView

/*!
 @abstract 数据源，都要是DFLogModel对象
 */
@property (retain, nonatomic) NSMutableArray<DFLogModel *> *items;
@end

/*!
 @abstract 日志界面容器，负责日志的弹出、隐藏、列表和数据库的交互
 */
@interface DFLogView : UIView

/*!
 @abstract 页面初始化
 */
+ (instancetype)shareLogView;

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
 @param model 日志对象
 */
- (void)add:(DFLogModel *)model;

/*!
 @abstract 批量删除日志对象
 @param indexSet 日志对象位于数据库的下标，按时间顺序倒叙
 */
- (void)deleteIndexes:(NSIndexSet *)indexSet;

/*!
 @abstract 日志数据清空
 */
- (void)deleteAll;

/*!
 @abstract  日志在app上唤出
 @param animations 弹出完成后回调
 */
- (void)showComplete:(void (^)(void))animations;

/*!
 @abstract 日志关闭
 */
- (void)close;

@end

