//
//  XDJDDLogManager.h
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface DFLogManager : NSObject

+ (instancetype)shareLogManager;

@property (retain, nonatomic, readonly) RLMRealm *realm;
//记录的最大条数，默认为50条，考虑到性能问题，插入数据时的要跟着刷新ui，所以运行时不实时删除，只在程序启动时过滤掉溢出的数据
@property (assign, nonatomic) NSInteger maxLogerCount;

- (void)updateSelector:(NSString *)selector
               request:(id)request
              response:(id)response
                 error:(NSError *)error;

- (void)reset;
@end
