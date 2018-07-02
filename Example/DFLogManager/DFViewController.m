//
//  DFViewController.m
//  DFLogManager
//
//  Created by acct<blob>=0xE585A8E7A88BE681BA on 01/26/2018.
//  Copyright (c) 2018 acct<blob>=0xE585A8E7A88BE681BA. All rights reserved.
//

#import "DFViewController.h"
#import "DFLogManager.h"
#import "DFLogView.h"

@interface DFViewController ()

@end

@implementation DFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(20, 40, 80, 40);
    [btn addTarget:self action:@selector(addNew) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.backgroundColor = [UIColor redColor];
    btn2.frame = CGRectMake(20, 120, 80, 40);
    [btn2 addTarget:self action:@selector(showReleaseView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.backgroundColor = [UIColor redColor];
    btn3.frame = CGRectMake(20, 200, 80, 40);
    [[DFLogManager shareLogManager] bindView:btn3 duringTime:2 targetCount:5];
    [self.view addSubview:btn3];
    
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn4.backgroundColor = [UIColor redColor];
    btn4.frame = CGRectMake(20, 280, 80, 40);
    [btn4 addTarget:self action:@selector(recordCount) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
}

- (void)addNew {
    
    DFLogModel *logModel = [DFLogModel new];
    logModel.selector = @"测试测试测试测试测试";
    logModel.requestObject = @"请求方法";
    logModel.responseObject = @"回参";
    logModel.error = arc4random() % 2 ? @"错误" : @"";
    [[DFLogManager shareLogManager] addLogModel:logModel];
}

- (void)showReleaseView {
    
    [[DFLogView shareLogView] showComplete:^{
        
    }];
}

- (void)recordCount {
    
    [[DFLogManager shareLogManager] recordCountDuringTime:2 targetCount:5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
