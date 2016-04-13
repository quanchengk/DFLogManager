//
//  XDJDDLogView.h
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//  调试页面调出

#import <UIKit/UIKit.h>
#import "DFLogManager.h"

@interface DFLogView : UIView {
    
    UITextView *_textView;
}

/**
 *  页面初始化
 */
+ (instancetype)shareLogView;

/**
 *  加入日志文本，自动同步到本地日志文件中
 *
 *  @param logStr 日志文本内容
 */
+ (void)addLogText:(NSString *)logStr;

/**
 *  日志在app上唤出
 */
- (void)show;

@end
