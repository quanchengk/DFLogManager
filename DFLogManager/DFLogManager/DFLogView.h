//
//  XDJDDLogView.h
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//  调试页面调出

#import <UIKit/UIKit.h>
#import "DFLogModel.h"

@interface DFLogView : UIView 

/**
 *  页面初始化
 */
+ (instancetype)shareLogView;

/**
 *  添加消息体
 */
- (void)add:(DFLogModel *)model;

/**
 *  realm的Auto-Update是个坑，让查询得到的数据与数据库中的数据保持了同步，所以删除的时候，假如realm已经删除了某条数据，而tableview的数据源还持有这个model的话，会造成访问野指针的情况，所以要特地开放删除的方法让manager在删除realm的同时，删除ui上对应的那条数据
 */
- (void)deleteIndexes:(NSIndexSet *)indexSet;

/**
 *  日志在app上唤出
 */
- (void)show;

@end
