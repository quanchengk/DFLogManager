//
//  DFLogCircleView.m
//  LSFrameWorkDemo
//
//  Created by 全程恺 on 2018/1/26.
//  Copyright © 2018年 全程恺. All rights reserved.
//

#import "DFLogCircleView.h"
#import "DFLogView.h"

#define DFScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define DFScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
static CGFloat selfWidth = 50;
static CGFloat circleWidth = 32;

@interface DFLogCircleView ()

@property (retain, nonatomic) UIButton *circleBtn;
@property (retain, nonatomic) UIActivityIndicatorView *indicatorView;
@end

@implementation DFLogCircleView

- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.hidesWhenStopped = YES;
        [self addSubview:_indicatorView];
        
        _indicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    }
    return _indicatorView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.frame = CGRectMake(0, (DFScreenHeight - selfWidth) / 2, selfWidth, selfWidth);
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.6];
        
        NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, circleWidth, circleWidth);
        btn.center = CGPointMake(selfWidth / 2, selfWidth / 2);
        [btn setBackgroundImage:[UIImage imageNamed:@"df_circle" inBundle:selfBundle compatibleWithTraitCollection:NULL] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"df_close" inBundle:selfBundle compatibleWithTraitCollection:NULL] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(showLogView:) forControlEvents:UIControlEventTouchUpInside];
        _circleBtn = btn;
        [self addSubview:btn];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSuspend:)];
        [self addGestureRecognizer:pan];
    }
    
    return self;
}

//移动悬浮球，加入粘性代码
- (void)moveSuspend:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication].delegate window];
    [keyWindow makeKeyWindow];
    point = [self convertPoint:point toView:keyWindow];
    self.center = point;
    
    switch (pan.state) {
            
        case UIGestureRecognizerStateEnded: {
            
            // 判断上下左右哪个挨得近
            CGFloat rateL = self.frame.origin.x / DFScreenWidth;
            CGFloat rateR = 1 - (self.frame.origin.x + self.frame.size.width) / DFScreenWidth;
            CGFloat rateT = self.frame.origin.y / DFScreenHeight;
            CGFloat rateB = 1 - (self.frame.origin.y + self.frame.size.height) / DFScreenHeight;
            // 比值越小，离得越近
            CGFloat rateMin = MIN(MIN(MIN(rateL, rateR), rateT), rateB);
            CGRect frame = self.frame;
            if (rateMin == rateL) {
                frame.origin.x = 0;
            }
            else if (rateMin == rateR) {
                frame.origin.x = DFScreenWidth - selfWidth;
            }
            else if (rateMin == rateT) {
                frame.origin.y = 0;
            }
            else if (rateMin == rateB) {
                frame.origin.y = DFScreenHeight - selfWidth;
            }
            
            [UIView animateWithDuration:.5
                                  delay:0
                 usingSpringWithDamping:.6
                  initialSpringVelocity:.2
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 self.frame = frame;
                             } completion:^(BOOL finished) {
                                 
                             }];
            [UIView animateWithDuration:0.5 animations:^{
                
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)show {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        popAnimation.duration = 0.5;
        popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DIdentity]];
        popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
        popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.circleBtn.layer addAnimation:popAnimation forKey:nil];
        self.circleBtn.transform = CGAffineTransformScale(self.transform,1,1);
        
        [self makeKeyAndVisible];
        
        UIWindow *keyWindow = [[UIApplication sharedApplication].delegate window];
        [keyWindow makeKeyWindow];
    });
}

- (void)showLogView:(UIButton *)btn {
    
    if (btn.selected) {
        [[DFLogView shareLogView] close];
    }
    else {
        
        NSLog(@"开始展示%@", [NSDate date]);
        btn.hidden = YES;
        [self.indicatorView startAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[DFLogView shareLogView] showComplete:^{
                
                NSLog(@"结束展示%@", [NSDate date]);
                btn.hidden = NO;
                [self.indicatorView stopAnimating];
            }];
        });
    }
    
    btn.selected = !btn.selected;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

