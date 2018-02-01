//
//  XDJDDLogManager.h
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "DFLogModel.h"

typedef NS_ENUM(NSInteger, DFLogType) {
    DFLogTypeNone,      // 无日志模式，不记录日志，且设置后会清空所有已记录的日志，无悬浮球
    DFLogTypeDebug,     // 调试模式，日志条数无上限，会显示悬浮球
    DFLogTypeRelease,   // 生产模式，普通日志保留50条，异常日志保留20条，悬浮球隐藏，后台记录
};

@interface DFLogManager : NSObject

// 是否开启调试模式，如果传YES，则会在界面上出现日志按钮，可随时唤出调试页面
@property (assign, nonatomic) DFLogType mode;
// 数据库载体
@property (retain, nonatomic, readonly) RLMRealm *realm;

+ (instancetype)shareLogManager;

- (void)addLogModel:(DFLogModel *)logModel;

- (void)reset;

@end

