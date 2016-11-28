//
//  LUColoringBorderView.m
//  Pods
//
//  Created by lunner on 8/7/16.
//
//

#import "LUColoringBorderView.h"

@implementation LUColoringBorderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _duration = 3.0;
            }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    [self.layer removeAnimationForKey:@"borderAnimation"];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    CAKeyframeAnimation *widthAnim = [CAKeyframeAnimation animationWithKeyPath:@"borderWidth"];
    widthAnim.values = self.widths;
    widthAnim.calculationMode = kCAAnimationPaced;
    
    CAKeyframeAnimation *colorAnim = [CAKeyframeAnimation animationWithKeyPath:@"borderColor"];
    colorAnim.values = self.colors;
    colorAnim.calculationMode = kCAAnimationPaced;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[colorAnim, widthAnim];
    group.duration = self.duration;
    group.repeatCount = NSIntegerMax;
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = YES;
    [self.layer addAnimation:group forKey:@"borderAnimation"];

}

- (NSArray<NSNumber *> *)widths {
    return [NSArray arrayWithObjects:@1.0, @10.0, @5.0, @30.0, @0.5, @15.0, @2., @50.0, @0.0, nil];
}

- (NSArray *)colors {
    return [NSArray arrayWithObjects:(id)[UIColor greenColor].CGColor,
            (id)[UIColor redColor].CGColor,
            (id)[UIColor blueColor].CGColor, nil];
}



@end
