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

@interface DFLogManager : NSObject

// 是否开启调试模式，如果传YES，则会在界面上出现日志按钮，可随时唤出调试页面
@property (assign, nonatomic) BOOL debugMode;
// 数据库载体
@property (retain, nonatomic, readonly) RLMRealm *realm;
// 记录的最大条数，默认为50条，考虑到性能问题，插入数据时的要跟着刷新ui，所以运行时不实时删除，只在程序启动时过滤掉溢出的数据
@property (assign, nonatomic) NSInteger maxLogerCount;

+ (instancetype)shareLogManager;

- (void)addLogModel:(DFLogModel *)logModel;

- (void)reset;

@end

