/*!
 @header DFLogView
 @abstract 日志展示的UI
 @author Created by 全程恺 on 2018/1/26
 @version 0.1.3
 Copyright © 2018年 danfort. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "DFLogModel.h"

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

