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
    btn2.frame = CGRectMake(20, 80, 80, 40);
    [btn2 addTarget:self action:@selector(showReleaseView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
