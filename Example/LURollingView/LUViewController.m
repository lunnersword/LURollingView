//
//  LUViewController.m
//  LURollingView
//
//  Created by bingchen on 05/17/2016.
//  Copyright (c) 2016 bingchen. All rights reserved.
//

#import "LUViewController.h"
#import <LURollingView/LURollingLabel.h>

@interface LUViewController ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) LURollingLabel *rollingLabel;
@end

@implementation LUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.frame  = CGRectMake(self.view.bounds.size.width*0.25, self.view.bounds.size.height - 50, self.view.bounds.size.width * 0.5, 50);
    [self.button setTitle:@"Start Animation" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(doButton) forControlEvents:UIControlEventTouchUpInside];

    self.rollingLabel = [LURollingLabel new];
    self.rollingLabel.frame = (CGRectMake(0, 300, self.view.bounds.size.width, 100));
    self.rollingLabel.texts = @[@"fuck ", @"do you love me", @"someOne payed someone some momey", @"you are young"];
    self.rollingLabel.rollingAnyway = YES;
    
    [self.view addSubview:self.button];
    [self.view addSubview:self.rollingLabel];

}
- (void)doButton {
    [self.rollingLabel start];
    //    [self doTransitionCircile];
    //[self doTransitionAnimation];
    //    [self transitionWithCIFilter];
    //    [self animationInUIView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
