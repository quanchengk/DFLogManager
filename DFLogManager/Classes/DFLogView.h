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

- (void)deleteIndexes:(NSIndexSet *)indexSet;

/**
 *  日志在app上唤出
 */
- (void)showComplete:(void (^)(void))animations;

- (void)close;

@end

