//
//  XDJDDLogView.m
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import "DFLogView.h"

static DFLogView *_instance;

@implementation DFLogView

+ (instancetype)shareLogView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.alpha = .7;
        self.backgroundColor = [UIColor clearColor];
        
        UIButton *scaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        scaleBtn.backgroundColor = [UIColor darkGrayColor];
        [scaleBtn setTitle:@"缩小" forState:UIControlStateNormal];
        [scaleBtn setTitle:@"放大" forState:UIControlStateSelected];
        scaleBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        resetBtn.backgroundColor = [UIColor darkGrayColor];
        [resetBtn setTitle:@"清空" forState:UIControlStateNormal];
        resetBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        updateBtn.backgroundColor = [UIColor darkGrayColor];
        [updateBtn setTitle:@"更新" forState:UIControlStateNormal];
        updateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        removeBtn.backgroundColor = [UIColor redColor];
        [removeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        removeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:resetBtn];
        [self addSubview:updateBtn];
        [self addSubview:removeBtn];
        [self addSubview:scaleBtn];
        
        [scaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.height.mas_equalTo(30);
            make.width.equalTo(updateBtn);
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self).offset(10);
        }];
        
        [updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.top.height.equalTo(resetBtn);
            make.left.equalTo(scaleBtn.mas_right).offset(10);
        }];
        
        [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.top.height.equalTo(removeBtn);
            make.left.equalTo(updateBtn.mas_right).offset(10);
        }];
        
        [removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.top.height.equalTo(scaleBtn);
            make.left.equalTo(resetBtn.mas_right).offset(10);
            make.right.equalTo(self).offset(-10);
        }];
        
        [[scaleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
            
            x.selected = !x.selected;
            if (x.selected) {
                
                [self mas_updateConstraints:^(MASConstraintMaker *make) {
                    
                    make.height.mas_equalTo(50);
                }];
            }
            else
                [self mas_updateConstraints:^(MASConstraintMaker *make) {
                    
                    make.height.mas_equalTo(400);
                }];
            
            [UIView animateWithDuration:.2
                             animations:^{
                                 
                                 [self layoutIfNeeded];
                             }];
        }];
        
        [[updateBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [self updateContent];
        }];
        
        [[resetBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[DFLogManager shareLogManager] reset];
                [self updateContent];
            });
        }];
        
        [[removeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [self removeFromSuperview];
        }];
        
        UITextView *textView = [UITextView new];
        textView.font = [UIFont boldSystemFontOfSize:12];
        textView.textColor = [UIColor blackColor];
        [self addSubview:textView];
        _textView = textView;
        
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self).offset(50).priorityHigh();
            make.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(400);
        make.right.left.top.equalTo(keyWindow);
    }];
    
    [self updateContent];
}

- (void)updateContent
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *logFilePath = [[DFLogManager shareLogManager] logsDirectory];
        NSData *logData = [NSData dataWithContentsOfFile:logFilePath];
        NSString *logStr = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _textView.text = logStr;
        });
    });
}

+ (void)addLogText:(NSString *)logStr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableString *mString = [NSMutableString stringWithString:@"\n"];
        [mString appendString:logStr];
        [mString appendString:@"\n"];
        DDLogInfo(mString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_instance updateContent];
        });
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
