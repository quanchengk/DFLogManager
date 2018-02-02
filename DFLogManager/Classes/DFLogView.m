//
//  XDJDDLogView.m
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import "DFLogView.h"
#import "DFLogManager.h"
#import <Masonry/Masonry.h>
#import "DFLogTableView.h"

#define DFScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface DFLogView () {
    
    DFLogTableView *_tableView;
    
    UIPanGestureRecognizer *_moveGesture;
    UIPanGestureRecognizer *_scaleGesture;
}

@property (retain, nonatomic) UIView *scaleView;
@end

@implementation DFLogView

static DFLogView *_instance;
+ (instancetype)shareLogView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (UIView *)scaleView {
    
    if (!_scaleView) {
        
        _scaleView = [UIView new];
        _scaleView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.1];
    }
    
    return _scaleView;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        UIView *moveableView = [[UIView alloc] init];
        moveableView.backgroundColor = [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:.8];
        _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePosition)];
        [moveableView addGestureRecognizer:_moveGesture];
        
        NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
        UIImageView *scalableIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        scalableIcon.image = [UIImage imageNamed:@"df_scale" inBundle:selfBundle compatibleWithTraitCollection:NULL];
        scalableIcon.contentMode = UIViewContentModeScaleAspectFit;
        scalableIcon.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.6];
        scalableIcon.userInteractionEnabled = YES;
        _scaleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scale)];
        [scalableIcon addGestureRecognizer:_scaleGesture];
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [resetBtn setTitle:@"清空" forState:UIControlStateNormal];
        
        _scaleView.hidden = YES;
        
        _tableView = [[DFLogTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
        [self addSubview:moveableView];
        [self addSubview:resetBtn];
        [self addSubview:_tableView];
        [self addSubview:scalableIcon];
        
        [moveableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.equalTo(self);
            make.top.equalTo(self);
        }];
        
        [scalableIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.bottom.equalTo(self);
            make.size.mas_equalTo(scalableIcon.frame.size);
        }];
        
        [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self).offset(15);
            make.top.equalTo(moveableView).offset(10);
            make.bottom.equalTo(moveableView).offset(-10);
            make.size.mas_equalTo(CGSizeMake(60, 30));
        }];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(resetBtn.mas_bottom).offset(10);
        }];
        
        [_scaleView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(self);
        }];
        
        [resetBtn addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
        
        if ([DFLogManager shareLogManager].mode == DFLogTypeRelease) {
            
            UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
            [self addSubview:closeBtn];
            [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
            [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.right.offset(-15);
                make.top.bottom.equalTo(resetBtn);
                make.size.equalTo(resetBtn);
            }];
        }
    }
    return self;
}


#pragma mark - action

- (void)movePosition {
    
    static CGPoint startPoint;
    static CGRect startFrame;
    switch (_moveGesture.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            startPoint = [_moveGesture locationInView:self.superview];
            startFrame = self.frame;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                CGPoint currentPoint = [_moveGesture locationInView:self.superview];
                
                CGRect frame = startFrame;
                double x = currentPoint.x - startPoint.x + startFrame.origin.x;
                if (x < 0) {
                    x = 0;
                }
                else if (x + startFrame.size.width > self.superview.frame.size.width) {
                    x = self.superview.frame.size.width - startFrame.size.width;
                }
                
                double y = currentPoint.y - startPoint.y + startFrame.origin.y;
                if (y < 0) {
                    
                    y = 0;
                }
                else if (y + startFrame.size.height > self.superview.frame.size.height) {
                    
                    y = self.superview.frame.size.height - startFrame.size.height;
                }
                frame.origin = CGPointMake(x, y);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.frame = frame;
                    [self layoutIfNeeded];
                });
            });
            break;
        }
            
        default:
            break;
    }
}

- (void)scale {
    
    static CGPoint startPoint;
    static CGRect startFrame;
    switch (_scaleGesture.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            [self.superview addSubview:self.scaleView];
            self.scaleView.frame = self.frame;
            startPoint = [_scaleGesture locationInView:self.superview];
            startFrame = self.frame;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                CGPoint currentPoint = [_scaleGesture locationInView:self.superview];
                CGRect frame = startFrame;
                
                CGFloat toWidth = currentPoint.x - startFrame.origin.x;
                if (toWidth < _scaleGesture.view.frame.size.width) {
                    
                    toWidth = _scaleGesture.view.frame.size.width;
                }
                
                CGFloat toHeight = currentPoint.y - startFrame.origin.y;
                if (toHeight < _scaleGesture.view.frame.size.height) {
                    
                    toHeight = _scaleGesture.view.frame.size.height;
                }
                
                frame.size = CGSizeMake(toWidth, toHeight);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    _scaleView.frame = frame;
                });
            });
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            self.frame = _scaleView.frame;
            [_scaleView removeFromSuperview];
            [self layoutIfNeeded];
            break;
        }
        default:
            break;
    }
}

- (void)reset {
    
    [[DFLogManager shareLogManager] reset];
}

- (void)showComplete:(void (^)(void))animations
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        
        self.frame = UIEdgeInsetsInsetRect(keyWindow.bounds, UIEdgeInsetsMake(20, 10, 110, 10));
    }
    if (animations) {
        animations();
    }
}

- (void)close {
    
    [self removeFromSuperview];
}

- (void)add:(DFLogModel *)model {
    
    [_tableView.items insertObject:model atIndex:0];
    [_tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)deleteAll {
    
    NSMutableIndexSet *set = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _tableView.items.count)];
    [_tableView.items removeAllObjects];
    [_tableView deleteSections:set withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteIndexes:(NSIndexSet *)indexSet {
    NSIndexSet *deleteIndexSet = [indexSet indexesWithOptions:0 passingTest:^BOOL(NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx > _tableView.items.count) {
            return NO;
        }
        return YES;
    }];
    
    [_tableView.items removeObjectsAtIndexes:deleteIndexSet];
    [_tableView reloadData];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end


