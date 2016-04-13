//
//  XDJDDLogManager.m
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import "DFLogManager.h"

@implementation DFLogManager

static DFLogManager *_instance;
+ (instancetype)shareLogManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:self];
        _fileLogger = fileLogger;
        fileLogger.maximumFileSize = 100000;
        
        //文件保存
        [DDLog addLogger:fileLogger];
        //控制台输出
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    return self;
}

- (NSString *)logsDirectory
{
    NSString *path =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *logPath = [path stringByAppendingPathComponent:@"log"];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    
    if (![fileManger fileExistsAtPath:logPath]){
        [fileManger createDirectoryAtPath:logPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [logPath stringByAppendingPathComponent:@"run.log"];;
}

- (NSArray *)unsortedLogFilePaths
{
    return nil;
}
- (NSArray *)unsortedLogFileNames
{
    return  nil;
}

- (NSArray *)unsortedLogFileInfos
{
    return nil;
}

- (NSArray *)sortedLogFilePaths
{
    return nil;
}

- (NSArray *)sortedLogFileNames
{
    return nil;
}

- (NSArray *)sortedLogFileInfos
{
    return nil;
}

- (NSString *)createNewLogFile
{
    NSString *fulPath = [self logsDirectory];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    
    BOOL isCreate = NO;
    
    if ([fileManger fileExistsAtPath:fulPath]) {
        
        if([[fileManger attributesOfItemAtPath:fulPath error:nil] fileSize] > 100000){
            [fileManger removeItemAtPath:fulPath error:nil];
            isCreate = YES;
        }
    }else{
        isCreate = YES;
    }
    
    if (isCreate) {
        [fileManger createFileAtPath:fulPath contents:nil attributes:nil];
    }
    
    return fulPath;
}

- (void)reset
{
    NSString *fulPath = [self logsDirectory];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    
    if ([fileManger fileExistsAtPath:fulPath]) {
        
        [fileManger removeItemAtPath:fulPath error:nil];
    }
    
    [fileManger createFileAtPath:fulPath contents:nil attributes:nil];
}

@end
