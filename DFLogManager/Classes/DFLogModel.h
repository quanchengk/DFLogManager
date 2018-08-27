/*!
 @header DFLogModel
 @abstract 日志对象数据模型
 @author Created by 全程恺 on 2018/1/26
 @version 0.1.3
 Copyright © 2018年 danfort. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>

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

