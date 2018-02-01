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

@interface DFLogManager : NSObject

// 是否开启调试模式，如果传YES，则会在界面上出现日志按钮，可随时唤出调试页面
@property (assign, nonatomic) BOOL debugMode;
// 数据库载体
@property (retain, nonatomic, readonly) DFLogDBManager *dbManager;

+ (instancetype)shareLogManager;

- (void)addLogModel:(DFLogModel *)logModel;

- (void)reset;

@end

