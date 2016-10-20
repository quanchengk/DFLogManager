//
//  XDJDDLogManager.h
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack.h>

#define addLogText(fmt, ...) [DFLogView addLogText:[NSString stringWithFormat:@"File:%s, \nLine:%d, \nFunction:%s, \nContent:%@\n", __FILE__, __LINE__ ,__FUNCTION__, [NSString stringWithFormat:fmt,##__VA_ARGS__]]]

static const int ddLogLevel = DDLogLevelVerbose;

@interface DFLogManager : NSObject <DDLogFileManager>
{
    DDFileLogger *_fileLogger;
}

+ (instancetype)shareLogManager;

//archived的最大次数，超过则把最开始archived的内容删掉
@property (readwrite, assign, atomic) NSUInteger maximumNumberOfLogFiles;
@property (readwrite, assign, atomic) unsigned long long logFilesDiskQuota;

- (NSString *)logsDirectory;
- (void)reset;
@end
