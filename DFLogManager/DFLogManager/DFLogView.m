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
        
        self.clipsToBounds = YES;
        
        UIView *moveableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
        moveableView.backgroundColor = [UIColor blueColor];
        _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePosition)];
        [moveableView addGestureRecognizer:_moveGesture];
        
        UIView *scalableView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x - 30, self.frame.origin.y - 30, 30, 30)];
        scalableView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.4];
        _scaleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scale)];
        [scalableView addGestureRecognizer:_scaleGesture];
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        resetBtn.backgroundColor = [UIColor darkGrayColor];
        [resetBtn setTitle:@"清空" forState:UIControlStateNormal];
        resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        removeBtn.backgroundColor = [UIColor redColor];
        [removeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        removeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        UITextField *searchTF = [UITextField new];
        searchTF.backgroundColor = [UIColor whiteColor];
        searchTF.placeholder = @"搜索关键字";
        searchTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        searchTF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        searchTF.delegate = self;
        searchTF.returnKeyType = UIReturnKeySearch;
        searchTF.clearButtonMode = UITextFieldViewModeAlways;
        searchTF.leftViewMode = UITextFieldViewModeAlways;
        searchTF.textAlignment = NSTextAlignmentCenter;
        _searchTF = searchTF;
        
        UILabel *leftLabel = [UILabel new];
        leftLabel.font = [UIFont systemFontOfSize:12];
        leftLabel.textColor = [UIColor darkGrayColor];
        searchTF.leftView = leftLabel;
        
        UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [preBtn setTitle:@"<" forState:UIControlStateNormal];
        [preBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        preBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _preBtn = preBtn;
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextBtn setTitle:@">" forState:UIControlStateNormal];
        [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _nextBtn = nextBtn;
        
        UITextView *textView = [UITextView new];
        textView.font = [UIFont boldSystemFontOfSize:12];
        textView.textColor = [UIColor blackColor];
        textView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.7];
        textView.editable = NO;
        [self addSubview:textView];
        _textView = textView;
        
        [self addSubview:moveableView];
        [self addSubview:resetBtn];
        [self addSubview:removeBtn];
        [self addSubview:searchTF];
        [self addSubview:preBtn];
        [self addSubview:nextBtn];
        [self addSubview:scalableView];
        
        resetBtn.frame = CGRectMake(30, moveableView.frame.size.height - 30, 50, 30);
        
        removeBtn.frame = CGRectMake(resetBtn.frame.size.width + resetBtn.frame.origin.x + 10, resetBtn.frame.origin.y, resetBtn.frame.size.width, resetBtn.frame.size.height);
        
        searchTF.frame = CGRectMake(150, resetBtn.frame.origin.y, 150, resetBtn.frame.size.height);
        preBtn.frame = CGRectMake(searchTF.frame.size.width + searchTF.frame.origin.x, resetBtn.frame.origin.y, 30, 30);
        nextBtn.frame = CGRectMake(preBtn.frame.size.width + preBtn.frame.origin.x, resetBtn.frame.origin.y, 30, 30);
        textView.frame = CGRectMake(0, moveableView.frame.origin.y + moveableView.frame.size.height, self.frame.size.width, self.frame.size.height - moveableView.frame.origin.y - moveableView.frame.size.height);
        
        self.autoresizesSubviews = YES;
        moveableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        scalableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [resetBtn addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
        [removeBtn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        [preBtn addTarget:self action:@selector(clickPre) forControlEvents:UIControlEventTouchUpInside];
        [nextBtn addTarget:self action:@selector(clickNext) forControlEvents:UIControlEventTouchUpInside];
        
        _searchRanges = [NSMutableArray array];
    }
    return self;
}

#pragma mark - action
- (void)reset {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[DFLogManager shareLogManager] reset];
        [self updateContent];
    });
}

- (void)remove {
    
    [self removeFromSuperview];
}

- (void)clickPre {
    
    NSInteger index = [_searchRanges indexOfObject:_selectRange];
    
    if (--index < 0) {
        
        index = _searchRanges.count - 1;
    }
    [self selectIndex:index];
}

- (void)clickNext {
    
    NSInteger index = [_searchRanges indexOfObject:_selectRange];
    
    if (++index >= _searchRanges.count) {
        
        index = 0;
    }
    
    [self selectIndex:index];
}

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
                frame.origin = CGPointMake(currentPoint.x - startPoint.x + startFrame.origin.x, currentPoint.y - startPoint.y + startFrame.origin.y);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.frame = frame;
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
                    
                    self.frame = frame;
                });
            });
            break;
        }
            
        default:
            break;
    }
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    self.frame = UIEdgeInsetsInsetRect(keyWindow.bounds, UIEdgeInsetsMake(20, 10, 10, 10));
    
    [self updateContent];
}

- (void)updateContent
{
    NSString *logFilePath = [[DFLogManager shareLogManager] logsDirectory];
    NSData *logData = [NSData dataWithContentsOfFile:logFilePath];
    _logStr = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
    [self search:_searchTF.text];
}

- (void)search:(NSString *)keyStr {
    
    [_searchRanges removeAllObjects];
    
    NSRange range = NSMakeRange(0, 0);
    do {
        
        range = [_logStr rangeOfString:keyStr options:NSCaseInsensitiveSearch range:NSMakeRange(range.length + range.location, _logStr.length - range.length - range.location)];
        if (range.length) {
            
            [_searchRanges addObject:[NSValue valueWithRange:range]];
        }
    } while (range.length);
    
    NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:_logStr];
    [mAttr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                           NSForegroundColorAttributeName: [UIColor blackColor],
                           NSBackgroundColorAttributeName: [UIColor clearColor]} range:NSMakeRange(0, _logStr.length)];
    for (NSValue *rangeValue in _searchRanges) {
        
        [mAttr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                               NSBackgroundColorAttributeName: [UIColor yellowColor]} range:[rangeValue rangeValue]];
    }
    UILabel *leftLabel = (UILabel *)_searchTF.leftView;
    _logAttr = mAttr;
    _textView.attributedText = [mAttr copy];
    
    if (_searchRanges.count) {
        
        [self selectIndex:0];
    }
    else {
        
        [_textView scrollRangeToVisible:NSMakeRange(_logStr.length - 1, 1)];
        leftLabel.text = @"";
        [leftLabel sizeToFit];
    }
}

- (void)selectIndex:(NSInteger)index {
    
    NSInteger preSelectRange = [_searchRanges indexOfObject:_selectRange];
    _selectRange = _searchRanges[index];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //文字变色
        [_logAttr beginEditing];
        //之前的文字颜色变正常
        if (_searchRanges.count > preSelectRange) {
            
            [_logAttr setAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor],
                                      NSFontAttributeName : [UIFont systemFontOfSize:14],
                                      NSBackgroundColorAttributeName: [UIColor yellowColor]} range:[_searchRanges[preSelectRange] rangeValue]];
        }
        
        //选中的文字颜色变红
        [_logAttr setAttributes:@{NSForegroundColorAttributeName: [UIColor redColor],
                                  NSFontAttributeName : [UIFont systemFontOfSize:17],
                                  NSBackgroundColorAttributeName: [UIColor yellowColor]} range:[_selectRange rangeValue]];
        [_logAttr endEditing];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _textView.attributedText = [_logAttr copy];
            [_textView scrollRangeToVisible:[_selectRange rangeValue]];
        });
    });
    
    UILabel *leftLabel = (UILabel *)_searchTF.leftView;
    leftLabel.text = [NSString stringWithFormat:@"%ld/%lu条 ", (long)index + 1, (unsigned long)_searchRanges.count];
    
    [leftLabel sizeToFit];
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

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self search:textField.text];
    [textField resignFirstResponder];
    
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
