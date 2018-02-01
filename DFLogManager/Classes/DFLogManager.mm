//
//  XDJDDLogManager.m
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import "DFLogManager.h"
#import "DFLogModel.h"
#import "DFLogView.h"
#import "DFLogCircleView.h"

@interface DFLogManager ()

@property (retain, nonatomic) DFLogCircleView *suspensionWindow;
@end

@implementation DFLogManager

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    
    DFLogModel *model = [DFLogModel new];
    model.selector = [NSString stringWithFormat:@"系统闪退：%@", name];
    model.requestObject = reason;
    model.responseObject = [DFLogManager stringWithJsonValue:arr];
    model.error = [DFLogManager stringWithJsonValue:exception.userInfo];
    
    [[DFLogManager shareLogManager] addLogModel:model];
}

static DFLogManager *_instance;
+ (instancetype)shareLogManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _dbManager = [DFLogDBManager new];
        
        //开启错误日志
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    }
    return self;
}

- (void)setDebugMode:(BOOL)debugMode {
    
    if (_debugMode != debugMode) {
        
        _debugMode = debugMode;
        
        if (debugMode) {
            
            DFLogCircleView *circleView = [[DFLogCircleView alloc] initWithFrame:CGRectZero];
            [circleView show];
            self.suspensionWindow = circleView;
        }
    }
}

- (void)addLogModel:(DFLogModel *)logModel {
    
    DFLogView *logerView = [DFLogView shareLogView];
    
    // 产生时间
    logModel.occurTime = [NSDate date];
    
    if (![logModel.requestObject isKindOfClass:[NSString class]]) {
        logModel.requestObject = [DFLogManager stringWithJsonValue:logModel.requestObject];
    }
    if (![logModel.responseObject isKindOfClass:[NSString class]]) {
        logModel.responseObject = [DFLogManager stringWithJsonValue:logModel.responseObject];
    }
    
    @try {
        
        [_dbManager saveModel:logModel];
    } @catch (NSException *exception) {
        
        //产生时间
        DFLogModel *errorModel = [DFLogModel new];
        errorModel.selector = logModel.selector;
        errorModel.error = [NSString stringWithFormat:@"realm插入错误：%@\n", exception];
        errorModel.requestObject = logModel.requestObject;
        errorModel.occurTime = [NSDate date];
        
        @try {
            
            [_dbManager saveModel:errorModel];
        } @catch (NSException *exception) {
            
        } @finally {
            
            [logerView add:errorModel];
        }
    } @finally {
        
        [logerView add:logModel];
    }
}

- (void)reset {
    
    BOOL res = [_dbManager deleteAllModel];
    if (res) {
        [[DFLogView shareLogView] deleteAll];
    }
}

+ (NSString *)stringWithJsonValue:(id)obj
{
    if (!obj) {
        
        return @"";
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        
        return obj;
    }
    NSError *error = nil;
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
    if(error){
        return obj;
    }
    NSString *str = [[NSString alloc]initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    return str ? str : obj;
}

@end
