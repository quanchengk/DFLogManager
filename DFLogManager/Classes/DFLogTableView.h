/*!
 @header DFLogTableView
 @abstract 日志展示的UI
 @author Created by 全程恺 on 2018/1/26
 @version 0.1.3
 Copyright © 2018年 danfort. All rights reserved.
 */

#import <UIKit/UIKit.h>

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
