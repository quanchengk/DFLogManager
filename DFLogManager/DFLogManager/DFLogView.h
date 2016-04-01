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
    
    UIScrollView *_sc;
    UIView *_contentView;
    UILabel *_contentLB;
}

+ (instancetype)shareLogView;
+ (void)addLogText:(NSString *)logStr;

- (void)show;

@end
