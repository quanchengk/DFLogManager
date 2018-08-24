/*!
 @header DFLogDBManager.h
 @abstract 日志数据库操作类
 @author Created by 全程恺 on 2018/1/26
 @version 0.1.3
 Copyright © 2018年 danfort. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DFLogModel.h"

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
