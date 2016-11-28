//
//  LUViewController.m
//  LURollingView
//
//  Created by bingchen on 05/17/2016.
//  Copyright (c) 2016 bingchen. All rights reserved.
//

#import "LUViewController.h"
#import "LUColoringBorderView.h"
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

    self.rollingLabel = [[LURollingLabel alloc] initWithFrame:CGRectZero rollModel:LURollingLabelRollModeGap direction:LURollingLabelRollDiretionVertical customClass:NULL];
    self.rollingLabel.frame = (CGRectMake(0, 300, self.view.bounds.size.width, 30));
    self.rollingLabel.individualTapBlock = ^(NSInteger index, UIView *view) {
        NSLog(@"INDIVIDUAL VIEW Tapped at index: %ld", index);
    };
    self.rollingLabel.respondsToTap = YES;
    self.rollingLabel.texts = @[@"fuck ", @"do you love me", @"someOne payed someone some momey", @"you are young", @"faldkjdfalfja;lf alfjalkdfaa jalkfja;lfdja;lfkja;lfdjal;fja;lfjalfja;ldjalfjajfa;lfja;lfjalfjal;falfjalfjafjal;dfjafjafjaldfkafja;jfd;afj;alfja;lfja;ldjfal;fja;lfdjal;dfja;ldfja;lja lk ;lfjal;jfal;fdjal;fjal;fj;lajdf;lafj;ajfladfja;djalfja;fja;fja;lf;"];
    self.rollingLabel.rollingAnyway = YES;
    
//    LUColoringBorderView *borderView = [LUColoringBorderView new];
//    borderView.frame = CGRectMake(0, 0, 100, 100);
//    [self.view addSubview:borderView];
    
    UIView *slipView = [[UIView alloc] initWithFrame:CGRectMake(-50, 0, 50, 50)];
//    slipView.backgroundColor = UIColor
    
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
