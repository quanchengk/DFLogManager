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
        
        NSString *fileStr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSURL *url = [[[NSURL fileURLWithPath:fileStr] URLByAppendingPathComponent:@"Debug"] URLByAppendingPathExtension:@"realm"];
        _realm = [RLMRealm realmWithURL:url];
        
        //开启错误日志
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
        _maxLogerCount = 5;
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
    NSNumber *maxRequestID = [[DFLogModel allObjectsInRealm:_realm] maxOfProperty:@"requestID"];
    logModel.requestID = [NSNumber numberWithInt:([maxRequestID intValue] + 1)];
    logModel.occurTime = [NSDate date];
    
    if (![logModel.requestObject isKindOfClass:[NSString class]]) {
        logModel.requestObject = [DFLogManager stringWithJsonValue:logModel.requestObject];
    }
    if (![logModel.responseObject isKindOfClass:[NSString class]]) {
        logModel.responseObject = [DFLogManager stringWithJsonValue:logModel.responseObject];
    }
    
    @try {
        
        [_realm transactionWithBlock:^{
            
            [_realm addObject:logModel];
        }];
    } @catch (NSException *exception) {
        
        NSNumber *maxRequestID = [[DFLogModel allObjectsInRealm:_realm] maxOfProperty:@"requestID"];
        //产生时间
        DFLogModel *errorModel = [DFLogModel new];
        errorModel.requestID = [NSNumber numberWithInt:([maxRequestID intValue] + 1)];
        errorModel.selector = logModel.selector;
        errorModel.error = [NSString stringWithFormat:@"realm插入错误：%@\n", exception];
        errorModel.requestObject = logModel.requestObject;
        errorModel.occurTime = [NSDate date];
        
        @try {
            
            [_realm transactionWithBlock:^{
                
                [_realm addObject:errorModel];
            }];
        } @catch (NSException *exception) {
            
        } @finally {
            
            [logerView add:errorModel];
            [self setMaxLogerCount:_maxLogerCount];
        }
    } @finally {
        
        [logerView add:logModel];
        [self setMaxLogerCount:_maxLogerCount];
    }
}

- (void)reset {
    
    [self saveLogerCount:0];
}

- (void)setMaxLogerCount:(NSInteger)maxLogerCount {
    
    _maxLogerCount = maxLogerCount;
    
    [self saveLogerCount:maxLogerCount];
}

- (void)saveLogerCount:(NSInteger)index {
    
    RLMResults *result = [[DFLogModel allObjectsInRealm:_realm] sortedResultsUsingKeyPath:@"requestID" ascending:NO];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *objects = [NSMutableArray array];
    for (NSInteger i = result.count - 1; i >= index; i--) {
        
        //多余的部分全部删掉
        DFLogModel *model = [result objectAtIndex:i];
        [objects addObject:model];
        [indexSet addIndex:i];
    }
    
    @try {
        
        [[DFLogView shareLogView] deleteIndexes:indexSet];
        [_realm transactionWithBlock:^{
            
            [_realm deleteObjects:objects];
        }];
    } @catch (NSException *exception) {
        
        NSLog(@"%@", exception);
    } @finally {
        
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
