/*!
 @header DFLogCircleView.h
 @abstract 悬浮圆球
 @author Created by 全程恺 on 2018/1/26
 @version 0.1.3
 Copyright © 2018年 danfort. All rights reserved.
 */

#import <UIKit/UIKit.h>

/*!
 @abstract 提供悬浮球样式，默认显示在屏幕左边垂直居中的位置，可随意拖动，松手后找最近的屏幕边吸附，点击后弹出日志列表，再次点击收起弹框
 */
@interface DFLogCircleView : UIWindow

/*!
 @abstract 弹出悬浮球
 @discussion 自带点击事件，只要告诉控件什么时候该显示即可
 @code
 
 DFLogCircleView *circleView = [[DFLogCircleView alloc] initWithFrame:CGRectZero];
 [circleView show];
 @endcode
 */
- (void)show;

@end
