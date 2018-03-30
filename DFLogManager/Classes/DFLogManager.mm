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

#define kDFReleaseNormalCount 50 // 日志保留正常条目的条数
#define kDFReleaseErrorCount 20  // 日志保留异常条目的条数
@interface DFLogManager ()

@property (retain, nonatomic) DFLogCircleView *suspensionWindow;

@property (retain, nonatomic) UIView *bindView;
@property (retain, nonatomic) UITapGestureRecognizer *tapGes;
@property (assign, nonatomic) NSInteger targetCount;
@property (assign, nonatomic) NSInteger currentCount;
@property (assign, nonatomic) NSInteger duringTime;

@end

@implementation DFLogManager

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    
    DFLogModel *model = [DFLogModel new];
    model.selector = [NSString stringWithFormat:@"系统闪退：%@", name];
    model.requestObject = reason;
    model.responseObject = [DFLogManager _stringWithJsonValue:arr];
    model.error = [DFLogManager _stringWithJsonValue:exception.userInfo];
    
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

- (UITapGestureRecognizer *)tapGes {
    
    if (!_tapGes) {
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_bindCount)];
    }
    
    return _tapGes;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        NSString *fileStr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSURL *url = [[[NSURL fileURLWithPath:fileStr] URLByAppendingPathComponent:@"log"] URLByAppendingPathExtension:@"realm"];
        _realm = [RLMRealm realmWithURL:url];
        
        //开启错误日志
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    }
    return self;
}

- (DFLogCircleView *)suspensionWindow {
    
    if (!_suspensionWindow) {
        
        DFLogCircleView *circleView = [[DFLogCircleView alloc] initWithFrame:CGRectZero];
        _suspensionWindow = circleView;
    }
    return _suspensionWindow;
}

- (void)setMode:(DFLogType)mode {
    
    _mode = mode;
    switch (mode) {
        case DFLogTypeNone:
            [_suspensionWindow resignKeyWindow];
            [self reset];
            break;
        case DFLogTypeDebug:
            [self.suspensionWindow show];
            break;
        case DFLogTypeRelease:
            [_suspensionWindow resignKeyWindow];
            // 保留固定条目
            [self _saveModelCountFrom:0 accrodingLimit:YES];
            break;
        default:
            break;
    }
}

- (void)bindView:(UIView *)view duringTime:(NSInteger)duringTime targetCount:(NSInteger)count {
    
    NSAssert([view isKindOfClass:[UIView class]] && count > 0, @"%s 要求必传监听对象，并且点击次数大于0", __func__);
    
    if ([_bindView isKindOfClass:[UIControl class]]) {
        [((UIControl *)_bindView) removeTarget:self action:@selector(_bindCount) forControlEvents:UIControlEventTouchUpInside];
    }
    _bindView = view;
    _targetCount = count;
    _duringTime = duringTime;
    _currentCount = 0;
    
    if ([view isKindOfClass:[UIControl class]]) {
        [((UIControl *)view) addTarget:self action:@selector(_bindCount) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        
        [view addGestureRecognizer:self.tapGes];
    }
}

- (void)textFieldContent:(NSString *)content modifyBlock:(void (^)(NSString *))modifyBlock {
    
    [[DFLogView shareLogView] textFieldContent:content modifyBlock:modifyBlock];
}

- (void)addLogModel:(DFLogModel *)logModel {
    
    if (self.mode == DFLogTypeNone) {
        return;
    }
    
    DFLogView *logerView = [DFLogView shareLogView];
    
    // 产生时间
    NSNumber *maxRequestID = [[DFLogModel allObjectsInRealm:_realm] maxOfProperty:@"requestID"];
    logModel.requestID = [NSNumber numberWithInt:([maxRequestID intValue] + 1)];
    logModel.occurTime = [NSDate date];
    
    if (![logModel.requestObject isKindOfClass:[NSString class]]) {
        logModel.requestObject = [DFLogManager _stringWithJsonValue:logModel.requestObject];
    }
    if (![logModel.responseObject isKindOfClass:[NSString class]]) {
        logModel.responseObject = [DFLogManager _stringWithJsonValue:logModel.responseObject];
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
        }
    } @finally {
        
        [logerView add:logModel];
    }
    
    if (self.mode == DFLogTypeRelease) {
        
        // 保留固定条目
        [self _saveModelCountFrom:0 accrodingLimit:YES];
    }
}

// 清空
- (void)reset {
    
    [self _saveModelCountFrom:0 accrodingLimit:NO];
}

- (void)_bindCount {
    
    if (_duringTime > 0) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(_resetCount) withObject:nil afterDelay:_duringTime];
    }
    
    NSLog(@"--------------- %ld", (long)_currentCount);
    if (++_currentCount >= _targetCount) {
        
        [[DFLogView shareLogView] showComplete:^{
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self _resetCount];
        }];
    }
}

- (void)_resetCount {
    
    _currentCount = 0;
}

// 从fromIndex开始移除日志，是否根据宏定义的个数约束条目
- (void)_saveModelCountFrom:(NSInteger)fromIndex accrodingLimit:(BOOL)accroding {
    
    RLMResults *result = [[DFLogModel allObjectsInRealm:_realm] sortedResultsUsingKeyPath:@"requestID" ascending:NO];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSMutableArray *objects = [NSMutableArray array];
    NSInteger errorCount = 0;
    NSInteger normalCount = 0;
    for (NSInteger i = 0; i < result.count; i++) {
        
        DFLogModel *model = [result objectAtIndex:i];
        
        if (accroding) {
            
            if (self.mode == DFLogTypeRelease) {
                
                // 常规记录个数
                // 超过阈值，开始把下标记录进要删除的数组容器
                if (model.error.length > 0) {
                    
                    if (++errorCount > kDFReleaseErrorCount) {
                        
                        [objects addObject:model];
                        [indexes addIndex:i];
                    }
                }
                else {
                    
                    if (++normalCount > kDFReleaseNormalCount) {
                        
                        [objects addObject:model];
                        [indexes addIndex:i];
                    }
                }
            }
            else if (i > fromIndex || self.mode == DFLogTypeNone) {
                
                switch (self.mode) {
                    case DFLogTypeNone:
                    case DFLogTypeDebug:
                        // DFLogTypeNone全部删
                        // DFLogTypeDebug 调用fromIndex后全部删
                        [objects addObject:model];
                        [indexes addIndex:i];
                        break;
                    case DFLogTypeRelease:
                        
                        break;
                    default:
                        break;
                }
            }
        }
        else {
            
            [objects addObject:model];
            [indexes addIndex:i];
        }
    }
    
    @try {
        
        [[DFLogView shareLogView] deleteIndexes:indexes];
        [_realm transactionWithBlock:^{
            
            [_realm deleteObjects:objects];
        }];
    } @catch (NSException *exception) {
        
        NSLog(@"%@", exception);
    } @finally {
        
    }
}

+ (NSString *)_stringWithJsonValue:(id)obj
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
